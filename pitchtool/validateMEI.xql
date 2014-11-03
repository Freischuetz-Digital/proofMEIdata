xquery version "3.0";

declare namespace mei="http://www.music-encoding.org/ns/mei";

(:declare option exist:serialize "method=text media-type=text/plain omit-xml-declaration=yes";:)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:media-type "application/json";


let $xml := request:get-data()
return
    (:transform:transform($xml, doc('/db/Website/resources/xslt/fastValidate.xsl'), ()):)
    validation:jing-report($xml, doc('freidi_pmd.rng'))
