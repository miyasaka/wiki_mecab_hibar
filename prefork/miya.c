#include <stdio.h>
#include <string.h>
#include <stdlib.h>

main(){
	char *pt;
	char buff[] = {"ＷＷＷ"};

	pt = getenv("HOSTNAME");
	fprintf(stdout,"Ret:[%s]\n",pt);
}


