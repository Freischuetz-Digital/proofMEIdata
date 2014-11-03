xquery version "3.0";

module namespace freidi-app="http://freischuetz-digital.de/freidi-tools/app";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://freischuetz-digital.de/tools/config" at "config.xqm";

declare function freidi-app:login() {
    try {
        let $user := request:get-parameter("username", ())
        let $password := request:get-parameter("password", ())
        let $loggedIn := xmldb:login("/db", $user, $password, false())
        return
            
            if (xmldb:get-current-user() != "guest" and xmldb:get-current-user() = $user) then (
                <response>
                    <user>{xmldb:get-current-user()}</user>
                </response>
            )else (
                <response>
                    <fail>Wrong user or password</fail>
                </response>
            )
    } catch * {
        <response>
            <fail>{$err:description}</fail>
        </response>
    }
};