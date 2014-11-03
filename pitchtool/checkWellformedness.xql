xquery version "3.0";

declare namespace mei="http://www.music-encoding.org/ns/mei";

declare option exist:serialize "method=text media-type=text/plain omit-xml-declaration=yes";

let $xml := request:get-parameter('xml', '')
return
    util:parse($xml)
