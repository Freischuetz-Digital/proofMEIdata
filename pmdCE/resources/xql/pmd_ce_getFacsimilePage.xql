xquery version "3.0";

import module namespace freidi-pmd="http://www.freischuetz-digital.de/proofMEIdata" at "../../../modules/app.xql";

declare namespace mei="http://www.music-encoding.org/ns/mei";

declare option exist:serialize "method=text media-type=text/plain omit-xml-declaration=yes";

let $path := request:get-parameter('path', '')

let $doc := doc('/db/apps/controlevents-data/' || $path)
             
let $surface := $doc//mei:surface[1]
let $graphic := $surface/mei:graphic[1]

let $path := $graphic/@target
let $pageN := $surface/@n

let $dw := 1200
let $wx := 0
let $wy := 0
let $ww := 1
let $wh := 1

let $imgSrc := concat($freidi-pmd:facsimileServerURI, '/digilib/Scaler/freidi/',$path,'?dw=',$dw,'&amp;amp;wx=',$wx,'&amp;amp;wy=',$wy,'&amp;amp;ww=',$ww,'&amp;amp;wh=',$wh)

return
    $imgSrc