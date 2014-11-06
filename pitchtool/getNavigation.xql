(:Freischütz-Digital
: pmd.pitchControl
: Copyright Johannes Kepper & Daniel Röwenstrunk 2012.
: kepper(at)edirom.de & roewenstrunk(at)edirom.de
:
: http://www.github.com/edirom/ediromSourceManager
:
: ## Description & License
:
: This returns JSON objects based on the eXist-db collections for the navigation
:
: This program is free software: you can redistribute it and/or modify
: it under the terms of the GNU General Public License as published by
: the Free Software Foundation, either version 3 of the License, or
: (at your option) any later version.
:
: This program is distributed in the hope that it will be useful,
: but WITHOUT ANY WARRANTY; without even the implied warranty of
: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
: GNU General Public License for more details.
:
: You should have received a copy of the GNU General Public License
: along with this program. If not, see <http://www.gnu.org/licenses/>.
:)
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
        where starts-with($page, $source)
        order by $page
        return
            '{"id": "' || substring-before($page, '.xml') || '",' ||
            '"path": "' || $source || '/' || $mdiv || '/' || $page || '"' ||
            '}'
};

declare function local:getStaves($source as xs:string, $mdiv as xs:string) as xs:string* {
    let $pages := collection('/db/apps/pitchtool-data/' || $source || '/' || $mdiv||'?select='||$source||'*.xml')
    let $staves := ($pages//mei:scoreDef)[1]//mei:staffDef
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
            '{"sigle": "' || $source || '",' ||
            '"mdivs": [' || string-join(local:getMdivs($source), ',') || ']' ||
            '}'
    , ',')
    || ']'

