xquery version "1.0";

declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace transform="http://exist-db.org/xquery/transform";

declare option exist:serialize "method=xml media-type=text/plain omit-xml-declaration=yes indent=yes";

let $fileName := request:get-parameter('file','')
let $filter := request:get-parameter('filter','')

let $basePath := if(starts-with($fileName,'/'))then('')else('/apps/verovio/samples/')
let $xslPath := if(starts-with($fileName,'/'))then('')else('../xslt/')

let $rawDoc := doc(concat($basePath,$fileName))
let $xsl := doc($filter)

let $parameters := <parameters></parameters>

let $doc := if($filter = '' or not(doc-available(concat($xslPath,$filter))))
            then($rawDoc)
            else(
                
                transform:transform($rawDoc,
                $xsl, $parameters)
            
            )

return
transform:transform($rawDoc,$xsl, $parameters)