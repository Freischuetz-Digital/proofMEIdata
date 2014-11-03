xquery version "3.0";

declare namespace mei="http://www.music-encoding.org/ns/mei";

declare option exist:serialize "method=text media-type=text/plain omit-xml-declaration=yes";


declare function local:getMdivs($source as xs:string) as xs:string* {
    let $mdivs := xmldb:get-child-collections('/db/apps/pitchtool-data/' || $source)
    return
        for $mdiv in $mdivs
        order by $mdiv
        return
            '{"id": "' || $mdiv || '",' ||
            '"pages": [' || string-join(local:getPages($source, $mdiv), ',') || '],' ||
            '"staves": [' || string-join(local:getStaves($source, $mdiv), ',') || ']' ||
            '}'
};

declare function local:getPages($source as xs:string, $mdiv as xs:string) as xs:string* {
    let $pages := xmldb:get-child-resources('/db/apps/pitchtool-data/' || $source || '/' || $mdiv)
    return
        for $page in $pages
        order by $page
        return
            '{"id": "' || substring-before($page, '.xml') || '",' ||
            '"path": "' || $source || '/' || $mdiv || '/' || $page || '"' ||
            '}'
};

declare function local:getStaves($source as xs:string, $mdiv as xs:string) as xs:string* {
    let $mdiv := doc('/db/apps/data/sources/' || substring-before($source, '_merged') || '.xml')/id($mdiv)
    let $staves := ($mdiv//mei:scoreDef)[1]//mei:staffDef
    return
        for $staff in $staves
        let $label := if($staff/@label)then($staff/@label)else($staff/../@label || ' (' || count($staff/preceding-sibling::mei:staffDef) + 1 || ')')
        return
            '{"n": "' || $staff/@n || '",' ||
            '"label": "' || $label || '"' ||
            '}'
};

let $sources := xmldb:get-child-collections('/db/apps/pitchtool-data')
return
    '[' || 
    string-join(
        for $source in $sources
        return
            '{"sigle": "' || substring-before($source, '_') || '",' ||
            '"mdivs": [' || string-join(local:getMdivs($source), ',') || ']' ||
            '}'
    , ',')
    || ']'

