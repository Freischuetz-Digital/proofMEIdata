xquery version "3.0";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace system="http://exist-db.org/xquery/system";
declare namespace transform="http://exist-db.org/xquery/transform";

declare option exist:serialize "method=xhtml media-type=text/html omit-xml-declaration=yes indent=yes";

declare function local:jsonifySlurs($slurs) {

    let $strings := for $elem in $slurs
                    
                    let $id := if($elem//@xml:id) then($elem//@xml:id[1]) else(generate-id($elem))
                    let $measureID := $elem/ancestor::mei:measure/@xml:id
                    let $measureN := $elem/ancestor::mei:measure/@n
                    
                    let $placement := if(local-name($elem) eq 'slur')
                                      then('obvious')
                                      else(
                                         if(count($elem//mei:reg) = 1)
                                         then('ambiguous')
                                         else('multiResolve')
                                      )
                    
                    let $startID := $elem//@startid[1]
                    let $endID := $elem//@endid[1]
                    
                    let $event := $elem/root()/id(substring($startID,2))
                    let $staff := $event/ancestor::mei:staff
                    let $layer :=  $event/ancestor::mei:layer
                    let $predecessors := $layer//mei:*[local-name() = ('note','chord') and not(parent::mei:chord) and following::mei:*[@xml:id = $event/@xml:id]]
                    
                    let $endEvent := $elem/root()/id(substring($endID,2))
                    let $endStaff := $endEvent/ancestor::mei:staff
                    let $endLayer :=  $endEvent/ancestor::mei:layer
                    let $endMeasure := $endLayer/ancestor::mei:measure
                    let $endPredecessors := $endLayer//mei:*[local-name() = ('note','chord') and not(parent::mei:chord) and following::mei:*[@xml:id = $endEvent/@xml:id]]
                    
                    let $curvedir := $elem//@curvedir[1]
                    let $staffText := $elem//@staff[1]
                    
                    (:new model:)
                    
                    let $startIDs := $elem//@startid/substring(.,2)
                    let $endIDs := $elem//@endid/substring(.,2)
                    let $tstamp := $elem//(@tstamp)[1]
                    let $tstamp2 := $elem//(@tstamp2)[1]
                    
                    
                    order by number($staffText) ascending
                    
                    return 
                        concat('{"id":"',$id,'",',
                            '"type":"slur",',
                            '"startIDs":[',if(count($startIDs) gt 0) then(concat('"',string-join($startIDs,'","'),'"')) else(),'],',
                            '"endIDs":[',if(count($endIDs) gt 0) then(concat('"',string-join($endIDs,'","'),'"')) else(),'],',
                            '"tstamp":"',$tstamp,'",',
                            '"tstamp2":"',$tstamp2,'",',
                            '"curvedir":"',$curvedir,'",',
                            '"staff":"',$staffText,'",',
                            '"startStaffID":"',$staff/@xml:id,'",',
                            '"endStaffID":"',$endStaff/@xml:id,'"',
                            '}')
                    
                        (:concat('{"id":"',$id,'",',
                        '"type":"slur",',
                        
                        
                        '"measureID":"',$measureID,'",',
                        '"measureN":"',$measureN,'",',
                        '"startLabel":"m',$measureN,', e',count($predecessors) + 1,'",',
                        '"endLabel":"m',$endMeasure/@n,', e',count($endPredecessors) + 1,'",',
                        '"endMeasureID":"',$endMeasure/@xml:id,'",',
                        '"curvedir":"',$curvedir,'",',
                        '"placement":"',$placement,'",',
                        
                        '"staff":"',$staffText,'",',
                        
                        '"startID":"',substring($startID,2),'",',
                        '"endID":"',substring($endID,2),'",',
                        
                        '"startStaffID":"',$staff/@xml:id,'",',
                        '"endStaffID":"',$endStaff/@xml:id,'"',
                        '}'):)
    
    return 
        string-join($strings,',')
    
};

declare function local:jsonifyDynams($dynams) {
    let $strings := for $dynam in $dynams
                    let $id := if($dynam/@xml:id) then($dynam/@xml:id) else(generate-id($dynam))
                    return 
                        concat('{"id":"',$id,'"}')
    
    return 
        string-join($strings,',')
    
};

declare function local:jsonifyHairpins($hairpins) {
    let $strings := for $hairpin in $hairpins
                    let $id := if($hairpin/@xml:id) then($hairpin/@xml:id) else(generate-id($hairpin))
                    return 
                        concat('{"id":"',$id,'"}')
    
    return 
        string-join($strings,',')
    
};

declare function local:jsonifyDirs($dirs) {
    let $strings := for $dir in $dirs
                    let $id := if($dir/@xml:id) then($dir/@xml:id) else(generate-id($dir))
                    return 
                        concat('{"id":"',$id,'"}')
    
    return 
        string-join($strings,',')
    
};

let $path := request:get-parameter('path', '')
let $staffN := request:get-parameter('staff', '')

let $doc := doc('/db/apps/controlevents-data/' || $path)

let $slurs := $doc//(mei:slur[not(./parent::mei:*/parent::mei:choice)]|mei:choice[.//mei:slur])
let $hairpins := $doc//mei:hairpin
let $dynams := $doc//mei:dynam
let $dirs := $doc//mei:dir

return
    (:concat('["',string-join($sources/@xml:id,'","'),'"]'):)
    (
        '{"slurs":[',
            local:jsonifySlurs($slurs),
        '],"hairpins":[',
            local:jsonifyHairpins($hairpins),
        '],"dynams":[',
            local:jsonifyDynams($dynams),
        '],"dirs":[',
            local:jsonifyDirs($dirs),
        ']}'
    
    )
    