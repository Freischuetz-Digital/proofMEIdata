(:Freischütz-Digital
: pmd.pitchControl
: Copyright Johannes Kepper & Benjamin W. Bohl 2012.
: kepper(at)edirom.de & bohl(at)edirom.de
:
: http://www.github.com/edirom/ediromSourceManager
:
: ## Description & License
:
: This file reads an eXist-db collection an checks the proofreading status
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

declare namespace request="http://exist-db.org/xquery/request";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace system="http://exist-db.org/xquery/system";
declare namespace transform="http://exist-db.org/xquery/transform";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";

(:declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=yes indent=yes";:)

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";


declare function local:checkStaves($item){

  let $xml := xmldb:document($item)
  let $values := distinct-values($xml//mei:scoreDef//mei:staffDef/@n)
  let $sequence := string-join($xml//mei:revisionDesc//mei:changeDesc[.//mei:ref/@target='#pmd'], ' ')
  let $checkedStaves := for $val in $values
                        where contains($sequence, $val)
                        return $val
  return
  
  (:if(every $val in $values
  satisfies contains($sequence, $val))
  then(true())
  else(false()):)
  
  (: count val contained in values divide by count(values)  :)
  
  count(distinct-values($values[.=$checkedStaves])) div count($values)


};

(:declare function local:querySourceCollectionUri($sourceCollection) {
(\:    let $siglum := collection($sourceCollection)//mei:fileDesc//mei:title/text():\)
    
    let $mdivs := xmldb:get-child-collections($sourceCollection)
    
    let $json := for $mdiv in $mdivs
                 let $collectionUri := ($sourceCollection||'/'||$mdiv)
                 let $collection := collection($collectionUri)
(\:                 let $label := collection($collectionUri)/mei:mdiv/@label:\)
                 let $collectionResources := xmldb:get-child-resources($collectionUri) (\: oder besser //mei:surface elemente zählen? :\)
                 return
                    concat(
                        '{"label":"',$mdiv,
                        '","pageCount":',count($collectionResources),
                        ',"pages": [',
                            string-join(for $item in $collection//mei:mei
                                        return 
                                            concat( '{',
                                                    '"pageNum":',$item//mei:surface/@n,
                                                    ',"filled":', (if($item//mei:note) then('true') else('false')),
                                                    ',"corrected":',(if(local:checkStaves($item))
                                                                    then('true') else('false')) (\: if revDesc enthält für jeden staff ein changeDesc:\)
                                            ),
                                        '},'
                            ),
                        '}]',
                        '}'
                      )
                    
    return
       (\: concat('{"label":"',
        $siglum,
        '","pages":',
        $mdivPageCount,
        ',"movements":[',
        string-join($json,','),
        ']}'):\)
     $json
};:)

declare function local:ls($collection as xs:string) as element()* {
  if (xmldb:collection-available($collection)) then
    (         
      for $child in xmldb:get-child-collections($collection)
      let $path := concat($collection, '/', $child)
      order by $child 
      return
        <collection name="{$child}" path="{$path}">
          {
            if (xmldb:collection-available($path)) then (  
              attribute {'files'} {count(xmldb:get-child-resources($path))},
              attribute {'cols'} {count(xmldb:get-child-collections($path))},
              sm:get-permissions(xs:anyURI($path))/*/@*
            )
            else 'no permissions'
          }
          {local:ls($path)}
        </collection>,

        for $child in xmldb:get-child-resources($collection)
        let $path := concat($collection, '/', $child)
        order by $child 
        return
          <resource name="{$child}" path="{$path}" mime="{xmldb:get-mime-type(xs:anyURI($path))}" size="{fn:ceiling(xmldb:size($collection, $child) div 1024)}">
            {sm:get-permissions(xs:anyURI($path))/*/@*}
          </resource>
    )
  else ()    
};

(:============================================================================================:)

let $collectionUri := '/db/apps/pitchtool-data'
let $collectionXML := local:ls($collectionUri)
(:let $json := for $sourceCollection in xmldb:get-child-collections($collectionUri)
             return
                element div{element div{$sourceCollection}, element div{local:querySourceCollectionUri($collectionUri ||'/' || $sourceCollection)}}
let $itemUri := doc('/db/contents/revisedStructure/mergedSources/KA2_page017.xml'):)
return
    (:concat('["',string-join($sources/@xml:id,'","'),'"]'):)
   (: (
        '{"sources":[',
        string-join($json,','),
        ']}'
    
    ):)
    element root {
(:        $collectionXML:)
        for $coll in $collectionXML/root()/collection
        return (
            element sources {
                element label {string($coll/@name)},
                for $mvmt in $coll/collection
                return
                    element movements {
                        attribute json:array {"true"},
                        element label {string($mvmt/@name)},
                        for $page in $mvmt/resource
                        return
                            element pages {
                                element checked { attribute json:literal{"true"},local:checkStaves($page/@path)},
                                element name {string($page/@name)},
                                element measures {count(doc($page/@path)//mei:measure)}
                            }
                    }
                
            }
        )
            
    }
