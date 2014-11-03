xquery version "3.0";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace system="http://exist-db.org/xquery/system";
declare namespace transform="http://exist-db.org/xquery/transform";

(:declare option exist:serialize "method=xml media-type=application/xml omit-xml-declaration=yes indent=yes";:)
declare option exist:serialize "method=xml media-type=text/plain omit-xml-declaration=yes";

let $path := request:get-parameter('path', '')
let $id := request:get-parameter('id', '')

let $doc := doc('/db/apps/controlevents-data/' || $path)
let $elem := $doc/id($id)

return $elem