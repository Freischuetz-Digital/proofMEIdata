xquery version "3.0";

import module namespace freidi-pmd="http://www.freischuetz-digital.de/proofMEIdata" at "../../../modules/app.xql";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace system="http://exist-db.org/xquery/system";
declare namespace transform="http://exist-db.org/xquery/transform";

declare option exist:serialize "method=xml media-type=text/plain omit-xml-declaration=yes indent=yes";

let $path := concat($freidi-pmd:ce-data,request:get-parameter('path', ''))
let $staffID := request:get-parameter('staffID', '')
let $id_prefix := request:get-parameter('id_prefix', '')
let $endPageName := request:get-parameter('endPageName','')

let $pageName := tokenize($path,'/')[last()]
let $endPagePath := replace($path,$pageName,$endPageName)
let $xslbase := concat(replace(system:get-module-load-path(), 'embedded-eXist-server', ''), '/../xsl/')

let $doc := if($id_prefix = 'slurEnd___' and $pageName != $endPageName)then(doc($endPagePath))else(doc($path))

let $snippet := transform:transform($doc, doc($xslbase || 'stripPage2staff.xsl'), <parameters><param name="staffID" value="{$staffID}"/><param name="id_prefix" value="{$id_prefix}"/><param name="path" value="{$path}"/><param name="endPageName" value="{$endPageName}"/></parameters>)
let $preparedSnippet := transform:transform($snippet, doc($xslbase || 'prepareRendering.xsl'), <parameters></parameters>)

return 
    $preparedSnippet