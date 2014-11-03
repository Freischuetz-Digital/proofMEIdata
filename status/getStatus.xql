xquery version "1.0";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace system="http://exist-db.org/xquery/system";
declare namespace transform="http://exist-db.org/xquery/transform";

declare option exist:serialize "method=xhtml media-type=text/html omit-xml-declaration=yes indent=yes";

declare function local:querySource($source) {
    let $siglum := string-join($source//mei:sourceDesc//mei:title/text(), '')
    let $measureCount := count($source//mei:measure)
    let $mdivs := $source//mei:mdiv
    let $json := for $mdiv in $mdivs
                 let $label := $mdiv/@label
                 return
                    concat(
                        '{"label":"',$label,
                        '","measures":',
                        count($mdiv//mei:measure),
                        ',"filled":',
                        if($mdiv//mei:note) then('true') else('false'),
                        '}'
                    )
    
    return
        concat('{"label":"',
        $siglum,
        '","measures":',
        $measureCount,
        ',"movements":[',
        string-join($json,','),
        ']}')
    
};


let $core := collection('/db/contents/revisedStructure/core.xml')//mei:mei
let $sources := collection('/db/contents/revisedStructure/sources')//mei:mei
let $json := for $source in $sources
             return
                local:querySource($source)

return
    (:concat('["',string-join($sources/@xml:id,'","'),'"]'):)
    (
        '{"sources":[',
        string-join($json,','),
        ']}'
    
    )
    