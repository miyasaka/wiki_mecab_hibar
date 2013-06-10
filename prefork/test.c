#include <stdio.h>
#include <unistd.h>
#define CALL_ENV "../shell/hibari_call.sh"
#define CALL_APP "hibari_call_shell.sh"
main(){

	execl(CALL_ENV,CALL_APP,"sfile_name.txtl",NULL);
	perror("faild exec");
	printf("not display\n");
}

