xquery version "3.0";

declare namespace mei="http://www.music-encoding.org/ns/mei";

declare option exist:serialize "method=text media-type=text/plain omit-xml-declaration=yes";

let $base := concat(replace(system:get-module-load-path(), 'embedded-eXist-server', ''), '/')
let $path := request:get-parameter('path', '')
let $staffN := request:get-parameter('staff', '')

let $mei := if($staffN = '') (:war: $path = '' or $staffN = '':)
            then(
                let $browserXML := request:get-data()
                return 
                    if($browserXML/mei:scoreDef)
                    then($browserXML)
                    else(
                        let $staffN := distinct-values($browserXML//mei:staff/@n)[1]
                        let $withDef := transform:transform($browserXML, doc($base || 'addScoreDef.xsl'), <parameters><param name="staffN" value="{$staffN}"/><param name="pageFilePath" value="/db/apps/pitchtool-data/{$path}"/></parameters>)
                        
                        return
                            transform:transform($withDef, doc($base || 'extractStaff.xsl'), <parameters><param name="staffN" value="{$staffN}"/><param name="mode" value="abc"/></parameters>)
                    )
            )
            else(
                let $doc := doc('/db/apps/pitchtool-data/' || $path)
                return
                    transform:transform($doc, doc($base || 'extractStaff.xsl'), <parameters><param name="staffN" value="{$staffN}"/><param name="mode" value="abc"/></parameters>)
            )

return
    transform:transform($mei, doc($base || 'mei2abc.xsl'), ())

