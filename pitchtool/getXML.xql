xquery version "3.0";

declare namespace mei="http://www.music-encoding.org/ns/mei";

declare option exist:serialize "method=xml media-type=text/plain omit-xml-declaration=yes";

let $base := concat(replace(system:get-module-load-path(), 'embedded-eXist-server', ''), '/')

let $path := request:get-parameter('path', '')
let $staffN := request:get-parameter('staff', '')

let $doc := doc('/db/apps/pitchtool-data/' || $path)

return
    transform:transform($doc, doc($base || 'extractStaff.xsl'), <parameters><param name="staffN" value="{$staffN}"/><param name="mode" value="ace"/></parameters>)