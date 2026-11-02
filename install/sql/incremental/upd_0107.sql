-- =============================================================
-- CA list corrections
-- Ref: issue #7017
-- Sources: CCADB AllCAAIdentifiersReport 2026-06-10
--          SSLMate CAA helper CA list 2026-06-10
--
-- Changes vs original:
--   REMOVE  - distrusted / defunct / removed CAs
--   UPDATE  - wrong ca_issue domains
--   UPDATE  - wrong / outdated ca_name values
--   ADD     - CAs missing from the table
-- =============================================================

-- -------------------------------------------------------------
-- REMOVE: distrusted / defunct CAs
-- -------------------------------------------------------------
-- WoSign: distrusted by all major browsers since 2016/2017 (certificate backdating, fraud)
DELETE FROM `dns_ssl_ca` WHERE `ca_issue` = 'wosign.com';
-- StartCom: distrusted by all major browsers; shut down January 2018
DELETE FROM `dns_ssl_ca` WHERE `ca_issue` = 'startcomca.com';
-- AC Camerfirma: distrusted by Chrome and Firefox for repeated compliance failures
DELETE FROM `dns_ssl_ca` WHERE `ca_issue` = 'camerfirma.com';
-- Entrust: distrusted by Chrome and Mozilla for new issuances since Nov 2024
DELETE FROM `dns_ssl_ca` WHERE `ca_issue` = 'entrust.net';
-- Symantec: distrusted by all browsers since 2018; CA sold to DigiCert
-- symantec.com remains a recognised alias under DigiCert but not a standalone entry
DELETE FROM `dns_ssl_ca` WHERE `ca_issue` = 'symantec.com';
-- PROCERT: Venezuelan CA with documented Mozilla compliance issues; ceased operations
DELETE FROM `dns_ssl_ca` WHERE `ca_issue` = 'procert.net.ve';
-- DocuSign: exited the CA business
DELETE FROM `dns_ssl_ca` WHERE `ca_issue` = 'docusign.fr';

-- -------------------------------------------------------------
-- UPDATE: wrong ca_issue domains
-- -------------------------------------------------------------
-- Certinomis: CCADB/SSLMate primary is www.certinomis.com; owner is now Docaposte
UPDATE `dns_ssl_ca`
  SET `ca_name`  = 'Certinomis (Docaposte)',
      `ca_issue` = 'www.certinomis.com'
  WHERE `ca_name` = 'Certinomis';
-- PKIoverheid: correct CAA domain pkioverheid.nl (was stored as a markdown hyperlink)
UPDATE `dns_ssl_ca`
  SET `ca_issue` = 'pkioverheid.nl'
  WHERE `ca_name` = 'PKIoverheid';
-- Chunghwa Telecom: CCADB/SSLMate primary is pki.hinet.net, not cht.com.tw
UPDATE `dns_ssl_ca`
  SET `ca_issue` = 'pki.hinet.net'
  WHERE `ca_name` = 'Chunghwa Telecom';
-- D-TRUST: CCADB/SSLMate primary is dtrust.de
UPDATE `dns_ssl_ca`
  SET `ca_issue` = 'dtrust.de'
  WHERE `ca_name` = 'D-TRUST';
-- Certizen: SSLMate primary is ecert.gov.hk (hongkongpost.gov.hk is secondary)
UPDATE `dns_ssl_ca`
  SET `ca_issue` = 'ecert.gov.hk'
  WHERE `ca_name` = 'Certizen';

-- -------------------------------------------------------------
-- UPDATE: outdated ca_name values
-- -------------------------------------------------------------
-- Asseco is the parent; Certum is the CA brand (CCADB: "Asseco Data Systems S.A.")
UPDATE `dns_ssl_ca`
  SET `ca_name` = 'Certum (Asseco Data Systems)'
  WHERE `ca_issue` = 'certum.pl';
-- Atos rebranded to Eviden in 2023 (CCADB: "Eviden")
UPDATE `dns_ssl_ca`
  SET `ca_name`  = 'Eviden (Atos TrustedRoot)',
      `ca_issue` = 'atos.net'
  WHERE `ca_name` = 'Atos TrustedRoot';
-- "(formerly Comodo CA)" is now ~6 years stale
UPDATE `dns_ssl_ca`
  SET `ca_name` = 'Sectigo'
  WHERE `ca_name` = 'Sectigo (formerly Comodo CA)';
-- DigiCert acquired Thawte, GeoTrust, RapidSSL; all covered by digicert.com
UPDATE `dns_ssl_ca`
  SET `ca_name` = 'DigiCert (incl. Thawte, GeoTrust, RapidSSL)'
  WHERE `ca_issue` = 'digicert.com';
-- T-Systems PKI business now operates as Deutsche Telekom Security GmbH
-- telesec.de is the CAA domain (SSLMate aka: "Deutsche Telekom Security GmbH, TeleSec, T-Systems")
UPDATE `dns_ssl_ca`
  SET `ca_name` = 'Deutsche Telekom Security (T-Systems)'
  WHERE `ca_name` = 'T-Systems';
-- WISeKey operates under the OISTE Foundation root (SSLMate primary name: "OISTE")
UPDATE `dns_ssl_ca`
  SET `ca_name` = 'OISTE (WISeKey)'
  WHERE `ca_issue` = 'wisekey.com';
-- Microsec is the correct short name (SSLMate: "Microsec"; product brand: e-Szigno)
UPDATE `dns_ssl_ca`
  SET `ca_name` = 'Microsec (e-Szigno)'
  WHERE `ca_name` = 'Microsec e-Szigno';
-- Sertifitseerimiskeskuse rebranded to SK ID Solutions; CAA domain is skidsolutions.eu
UPDATE `dns_ssl_ca`
  SET `ca_name`  = 'SK ID Solutions',
      `ca_issue` = 'skidsolutions.eu'
  WHERE `ca_issue` = 'sk.ee';

-- -------------------------------------------------------------
-- ADD: CAs missing from the table
-- -------------------------------------------------------------
INSERT INTO `dns_ssl_ca`
  (`id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `active`, `ca_name`, `ca_issue`, `ca_wildcard`, `ca_iodef`, `ca_critical`)
VALUES
  -- Apple: publicly trusted CA (SSLMate)
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Apple',                               'pki.apple.com',             'Y', '', 0),
  -- ANF AC: Spanish CA in Mozilla root store
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'ANF AC',                              'anf.es',                    'Y', '', 0),
  -- BJCA: Beijing Certificate Authority in Mozilla root store
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'BJCA',                                'bjca.cn',                   'Y', '', 0),
  -- Certicámara: Colombian CA in Mozilla root store (CCADB)
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Certicámara',                         'certicamara.com',           'Y', '', 0),
  -- Certigna: French CA by Dhimyotis/Tessi; in Mozilla root store
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Certigna',                            'certigna.fr',               'Y', '', 0),
  -- Certainly: Fastly's publicly trusted CA; accepted by Mozilla/Apple/Google since 2023
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Certainly',                           'certainly.com',             'Y', '', 0),
  -- Cybertrust Japan / JCSI: Japanese CA in Mozilla root store
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Cybertrust Japan / JCSI',             'cybertrust.co.jp',          'Y', '', 0),
  -- DFN-PKI: German research network CA (SSLMate); intermediate under Deutsche Telekom
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'DFN-PKI',                             'pki.dfn.de',                'Y', '', 0),
  -- eMudhra / emSign: Indian CA in Mozilla root store
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'emSign (eMudhra)',                     'emsign.com',                'Y', '', 0),
  -- Eviden (Atos TrustedRoot): German CA; Mozilla-trusted roots added 2021; rebranded 2023
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Eviden (Atos TrustedRoot)',            'atos.net',                  'Y', '', 0),
  -- GDCA: Chinese CA in Mozilla root store
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'GDCA',                                'gdca.com.cn',               'Y', '', 0),
  -- GLOBALTRUST: Austrian CA (e-commerce monitoring GmbH); in SSLMate list
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'GLOBALTRUST',                         'globaltrust.eu',            'Y', '', 0),
  -- GRCA: Government of Taiwan Root Certification Authority (SSLMate)
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'GRCA',                                'gca.nat.gov.tw',            'Y', '', 0),
  -- iTrusChina: Chinese CA in Mozilla root store
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'iTrusChina',                          'itrus.cn',                  'Y', '', 0),
  -- KIR: Polish CA in Mozilla root store
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'KIR (Poland)',                        'elektronicznypodpis.pl',    'Y', '', 0),
  -- KPN: Dutch telecom CA (SSLMate)
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'KPN',                                 'kpn.com',                   'Y', '', 0),
  -- MULTICERT: Portuguese CA in Mozilla root store (CCADB)
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'MULTICERT',                           'multicert.com',             'Y', '', 0),
  -- NAVER Cloud Trust Services: Korean CA in Mozilla root store
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'NAVER Cloud Trust Services',          'navercloudtrust.com',       'Y', '', 0),
  -- Network Solutions (Web.com): US registrar CA (SSLMate)
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Network Solutions (Web.com)',          'web.com',                   'Y', '', 0),
  -- PostSignum: Czech postal CA in Mozilla root store (CCADB)
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'PostSignum',                          'postsignum.cz',             'Y', '', 0),
  -- SHECA: Shanghai Electronic Certification Authority in Mozilla root store
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'SHECA',                               'sheca.com',                 'Y', '', 0),
  -- SK ID Solutions: Estonian CA; rebranded from Sertifitseerimiskeskuse; CAA: skidsolutions.eu
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'SK ID Solutions',                     'skidsolutions.eu',          'Y', '', 0),
  -- SSL.com: major commercial CA; also now backend for Entrust issuances
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'SSL.com',                             'ssl.com',                   'Y', '', 0),
  -- Swiss Federal IT (FOITT): admin.ch CA in CCADB
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Swiss Federal IT (FOITT)',            'admin.ch',                  'Y', '', 0),
  -- TrustAsia: widely used Asia-Pacific CA in Mozilla root store
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'TrustAsia',                           'trustasia.com',             'Y', '', 0),
  -- TunTrust: Tunisian national CA (ANCE) in Mozilla root store
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'TunTrust (ANCE)',                     'tuntrust.tn',               'Y', '', 0),
  -- TWCA: Taiwan CA in Mozilla root store
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'TWCA',                                'twca.com.tw',               'Y', '', 0),
  -- Viking Cloud (Trustwave / SecureTrust): rebranded from Trustwave (SSLMate)
  (NULL, 1, 1, 'riud', 'riud', '', 'Y', 'Viking Cloud (Trustwave)',             'trustwave.com',             'Y', '', 0);
-- The public key comment contains the domain or user name, so ssh-keygen output for a
-- 3072 bit key with a long domain name exceeds 600 characters (#7074).
ALTER TABLE `client` CHANGE `ssh_rsa` `ssh_rsa` text;
ALTER TABLE `sys_user`
	CHANGE `id_rsa` `id_rsa` text,
	CHANGE `ssh_rsa` `ssh_rsa` text;

-- Give the caching_sha2_password hash column the same length as the other password columns,
-- the generated hash is exactly 70 characters long and pre-hashed values passed through the
-- remote API (e.g. by the Migration Tool) can be longer (#7074).
ALTER TABLE `web_database_user` CHANGE `database_password_sha2` `database_password_sha2` varchar(255) DEFAULT NULL;
