<?php
/**
 * limits_registry
 *
 * Generic drop-in registry for client / reseller / client_template limits.
 *
 * Modules may register additional limit fields without modifying the limit
 * forms, templates, language files or the dashboard dashlet. Each provider
 * drops one definition file into:
 *
 *     interface/web/client/lib/limits.d/<name>.php
 *
 * The file returns an array describing one or more limit columns (see the
 * format below). The registry then:
 *
 *   - injects the fields into the "limits" tab of the client / reseller /
 *     client_template form definitions, so tform validates and persists them
 *     and the SOAP API exposes them (apply_to_form());
 *   - provides the render data for the generic accordion loop in the three
 *     limit templates (get_template_sections());
 *   - provides label texts for placeholders outside the loop and for the
 *     dashboard dashlet (get_labels());
 *   - provides dashlet usage entries (get_dashlet_limits()).
 *
 * The provider owns its database schema (the ALTER TABLE that adds the limit
 * columns) and its enforcement (the checkClientLimit()/checkResellerLimit()
 * calls in its own edit controllers).
 *
 * Definition file format (returns an array):
 *
 *   return array(
 *       'extension' => 'example',          // unique key, used for dedup
 *       'min_core'  => '3.3.2',            // optional minimum core version
 *       'section'   => array(             // accordion panel for the fields
 *           'id'    => 'Example',         // -> panel id "collapseExample"
 *           'title' => 'Example limits',  // panel heading
 *           'order' => 80,                // sort order among panels
 *       ),
 *       'limits' => array(
 *           'limit_example' => array(
 *               'label'      => 'Max. number of examples',
 *               'datatype'   => 'INTEGER',
 *               'formtype'   => 'TEXT',
 *               'default'    => '-1',
 *               'validators' => array(
 *                   // errmsg carries the message text directly so it renders
 *                   // verbatim if it is not found in the form wordbook.
 *                   array('type' => 'ISINT',
 *                         'errmsg' => 'Max. number of examples must be a number.'),
 *               ),
 *               'applies_to' => array('client', 'reseller', 'client_template'),
 *               'usage'      => array(   // optional dashlet usage reporting
 *                   'db_table' => 'example_table',
 *                   'db_where' => '',
 *                   // 'q_type' => 'quota',   // set for sum/quota style limits
 *               ),
 *           ),
 *       ),
 *   );
 *
 * Naming rule (hard requirement): every limit column name must contain the
 * substring "limit" so client_templates::apply_client_templates() recognises
 * it as a limit during template merging.
 *
 * @author Till Brehm, ISPConfig
 */

class limits_registry {

	/** @var array|null per-request cache of merged definitions keyed by extension */
	private static $cache = null;

	/** @var array per-request cache of existing columns: table => array(column => true) */
	private static $columns = array();

	/**
	 * Scan interface/web/client/lib/limits.d/ for definition files, validate and
	 * merge them. Result is cached for the duration of the request.
	 *
	 * @return array extension => definition
	 */
	public static function get() {
		if(self::$cache !== null) return self::$cache;
		self::$cache = array();

		$dir = ISPC_WEB_PATH.'/client/lib/limits.d';
		if(!is_dir($dir)) return self::$cache;

		$files = glob($dir.'/*.php');
		if(!is_array($files)) return self::$cache;

		foreach($files as $file) {
			$def = include $file;
			if(!is_array($def) || empty($def['extension']) || empty($def['limits']) || !is_array($def['limits'])) {
				continue;
			}
			// Skip a provider that requires a newer core than the one installed.
			// Development trees carry a non-release version suffix and are
			// always treated as current, so the feature stays testable there.
			if(!empty($def['min_core']) && defined('ISPC_APP_VERSION')) {
				if(stripos(ISPC_APP_VERSION, 'dev') === false
				   && version_compare(ISPC_APP_VERSION, $def['min_core'], '<')) {
					continue;
				}
			}
			self::$cache[$def['extension']] = $def;
		}

		return self::$cache;
	}

	/**
	 * Whether $column exists in $table. The column list per table is read once
	 * per request via SHOW COLUMNS. This is the guard that keeps a partially
	 * installed provider (definition file present, columns not yet added) from
	 * breaking the limit forms or the SOAP API with a missing-column SQL error.
	 *
	 * @param string $table
	 * @param string $column
	 * @return bool
	 */
	private static function column_exists($table, $column) {
		global $app;

		if(!isset(self::$columns[$table])) {
			self::$columns[$table] = array();
			$cols = $app->db->queryAllRecords("SHOW COLUMNS FROM ??", $table);
			if(is_array($cols)) {
				foreach($cols as $c) {
					if(isset($c['Field'])) self::$columns[$table][$c['Field']] = true;
				}
			}
		}

		return isset(self::$columns[$table][$column]);
	}

	/**
	 * The table that backs a given limit form. Resellers are stored in the
	 * client table, so both the client and reseller forms map to "client".
	 *
	 * @param string $form_name
	 * @return string
	 */
	private static function table_for_form($form_name) {
		return ($form_name == 'client_template') ? 'client_template' : 'client';
	}

	/**
	 * The default accordion section used when a definition omits 'section'.
	 *
	 * @param array $def
	 * @return array
	 */
	private static function section_of($def) {
		if(isset($def['section']) && is_array($def['section'])) {
			return array(
				'id'    => isset($def['section']['id'])    ? $def['section']['id']    : 'Extensions',
				'title' => isset($def['section']['title']) ? $def['section']['title'] : 'Extensions',
				'order' => isset($def['section']['order']) ? (int)$def['section']['order'] : 100,
			);
		}
		return array('id' => 'Extensions', 'title' => 'Extensions', 'order' => 100);
	}

	/**
	 * Flatten the registry to the limits that apply to $form_name and whose
	 * backing column actually exists. Each returned field is annotated with the
	 * resolved section under the '_section' key.
	 *
	 * @param string $form_name 'client' | 'reseller' | 'client_template'
	 * @return array limit_name => field definition
	 */
	public static function get_for_form($form_name) {
		$out = array();
		$table = self::table_for_form($form_name);

		foreach(self::get() as $def) {
			$section = self::section_of($def);
			foreach($def['limits'] as $name => $field) {
				if(!is_array($field)) continue;
				$applies = (isset($field['applies_to']) && is_array($field['applies_to']))
					? $field['applies_to']
					: array('client', 'reseller', 'client_template');
				if(!in_array($form_name, $applies, true)) continue;
				if(!self::column_exists($table, $name)) continue;
				$field['_section'] = $section;
				$out[$name] = $field;
			}
		}

		return $out;
	}

	/**
	 * Append the registered fields into the "limits" tab of a form definition.
	 * Call this at the end of the client / reseller / client_template tform
	 * files. This is what makes tform validate, read and write the columns and
	 * what exposes them via the SOAP API.
	 *
	 * @param array  $form      the form definition (by reference)
	 * @param string $form_name 'client' | 'reseller' | 'client_template'
	 */
	public static function apply_to_form(&$form, $form_name) {
		if(!isset($form['tabs']['limits']['fields']) || !is_array($form['tabs']['limits']['fields'])) {
			return;
		}

		foreach(self::get_for_form($form_name) as $name => $def) {
			$field = array(
				'datatype'   => isset($def['datatype']) ? $def['datatype'] : 'INTEGER',
				'formtype'   => isset($def['formtype']) ? $def['formtype'] : 'TEXT',
				'default'    => isset($def['default'])  ? $def['default']  : '-1',
				'validators' => (isset($def['validators']) && is_array($def['validators'])) ? $def['validators'] : array(),
				'value'      => isset($def['value'])    ? $def['value']    : '',
			);
			// Pass optional tform field keys through verbatim so any field type
			// (not just INTEGER/TEXT) is supported.
			foreach(array('separator', 'width', 'maxlength', 'regex', 'filters') as $k) {
				if(isset($def[$k])) $field[$k] = $def[$k];
			}
			if(!isset($field['width']))     $field['width']     = '10';
			if(!isset($field['maxlength'])) $field['maxlength'] = '10';

			$form['tabs']['limits']['fields'][$name] = $field;
		}
	}

	/**
	 * Build the loop data for the generic accordion block in the limit
	 * templates, grouped into sections and ordered by section order. Field
	 * values are taken from $record (falling back to the field default) and are
	 * HTML-escaped so arbitrary field types can be rendered safely.
	 *
	 * @param string $form_name 'client' | 'reseller' | 'client_template'
	 * @param array  $record    the currently loaded data record
	 * @return array list of sections, each:
	 *   array('section_id'=>.., 'section_title'=>.., 'fields'=>array(
	 *       array('name'=>.., 'label'=>.., 'value'=>..), ..))
	 */
	public static function get_template_sections($form_name, $record) {
		global $app;

		if(!is_array($record)) $record = array();
		$sections = array();

		foreach(self::get_for_form($form_name) as $name => $def) {
			$sid = $def['_section']['id'];
			if(!isset($sections[$sid])) {
				$sections[$sid] = array(
					'section_id'    => $def['_section']['id'],
					'section_title' => $def['_section']['title'],
					'section_order' => $def['_section']['order'],
					'fields'        => array(),
				);
			}
			$value = isset($record[$name])
				? $record[$name]
				: (isset($def['default']) ? $def['default'] : '');
			$sections[$sid]['fields'][] = array(
				'name'  => $name,
				'label' => isset($def['label']) ? $def['label'] : $name,
				'value' => $value,
			);
		}

		$sections = array_values($sections);
		usort($sections, function($a, $b) {
			if($a['section_order'] == $b['section_order']) return 0;
			return ($a['section_order'] < $b['section_order']) ? -1 : 1;
		});

		// Escape values and labels before they reach the template.
		return $app->functions->htmlentities($sections);
	}

	/**
	 * Label texts keyed '<limit>_txt' => '<label>', for placeholders rendered
	 * outside the accordion loop (e.g. the dashboard dashlet).
	 *
	 * @return array
	 */
	public static function get_labels() {
		$labels = array();
		foreach(self::get() as $def) {
			foreach($def['limits'] as $name => $field) {
				if(is_array($field) && isset($field['label'])) {
					$labels[$name.'_txt'] = $field['label'];
				}
			}
		}
		return $labels;
	}

	/**
	 * Entries shaped like the dashboard limits dashlet $limits[] array, for
	 * every limit that declares a 'usage' block and whose column exists in the
	 * client table.
	 *
	 * @return array
	 */
	public static function get_dashlet_limits() {
		$out = array();
		foreach(self::get() as $def) {
			foreach($def['limits'] as $name => $field) {
				if(!is_array($field) || empty($field['usage']) || !is_array($field['usage'])) continue;
				if(!self::column_exists('client', $name)) continue;
				$db_table = isset($field['usage']['db_table']) ? $field['usage']['db_table'] : '';
				if($db_table == '') continue;
				$entry = array(
					'field'    => $name,
					'db_table' => $db_table,
					'db_where' => isset($field['usage']['db_where']) ? $field['usage']['db_where'] : '',
				);
				if(isset($field['usage']['q_type']) && $field['usage']['q_type'] != '') {
					$entry['q_type'] = $field['usage']['q_type'];
				}
				$out[] = $entry;
			}
		}
		return $out;
	}
}
