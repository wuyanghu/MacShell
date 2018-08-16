 #!/bin/bash

whoami
cd $whoami
result=$(cat .arcrc)
echo $result

