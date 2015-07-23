kill -9 $(lsof -i tcp:4567 | awk '{if(NR>1)print $2}') ;
