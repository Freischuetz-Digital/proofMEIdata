xquery version "3.0";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace system="http://exist-db.org/xquery/system";
declare namespace transform="http://exist-db.org/xquery/transform";

declare option exist:serialize "method=xhtml media-type=text/html omit-xml-declaration=yes indent=yes";

let $type := request:get-parameter('type', '')
let $id := request:get-parameter('id', '')

let $elem := if($type eq 'slur')
             then(
                <slur xmlns="http://www.music-encoding.org/ns/mei" xml:id="{$id}" sameas="" startid="" endid="" staff="" curvedir="above"/>
             )
             else(
             
                if($type eq 'hairpin')
                then(
                    <hairpin xmlns="http://www.music-encoding.org/ns/mei" xml:id="{$id}" sameas="" startid="" endid="" form="cres"/>
                )
                else(
                    
                    if($type eq 'dynam')
                    then(
                        <dynam xmlns="http://www.music-encoding.org/ns/mei" xml:id="{$id}"/>
                    )
                    else(
                     
                        if($type eq 'dir')
                        then(
                            <dir xmlns="http://www.music-encoding.org/ns/mei" xml:id="{$id}"/>
                        )
                        else(
                        )
                    )
                )
             )

return
    $elem
