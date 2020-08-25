// TODO find better way
function getEnvValue(envVar) {
   run("sh", "-c", `printenv ${envVar} >/tmp/${envVar}.txt`);
   var value = cat(`/tmp/${envVar}.txt`);
   run("sh", "-c", `rm /tmp/${envVar}.txt`);
   return value.trim();
}

db.createUser(
    {
        user  : getEnvValue('DB_KYARU_USER'),
        pwd   : getEnvValue('DB_KYARU_PSWD'),
        roles : [
            {
                role : "readWrite",
                db   : "testingphase"
            }
        ]
    }
)