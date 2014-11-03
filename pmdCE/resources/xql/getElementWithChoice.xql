xquery version "3.0";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace system="http://exist-db.org/xquery/system";
declare namespace transform="http://exist-db.org/xquery/transform";

declare option exist:serialize "method=xhtml media-type=text/html omit-xml-declaration=yes indent=yes";

let $xml := request:get-parameter('xml', '')
let $startIDstring := request:get-parameter('startIDs', '')
let $endIDstring := request:get-parameter('endIDs', '')
let $tstamp := request:get-parameter('tstamp', '')
let $tstamp2 := request:get-parameter('tstamp2', '')

let $xslbase := concat(replace(system:get-module-load-path(), 'embedded-eXist-server', ''), '/../xsl/')

let $input := util:parse($xml)


let $output := transform:transform($input, doc($xslbase || 'wrapWithChoice.xsl'), <parameters>
        <param name="startIDs" value="{$startIDstring}"/>
        <param name="endIDs" value="{$endIDstring}"/>
        <param name="tstamp" value="{$tstamp}"/>
        <param name="tstamp2" value="{$tstamp2}"/>
    </parameters>)


return
    $output
