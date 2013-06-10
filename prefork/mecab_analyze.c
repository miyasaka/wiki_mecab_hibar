#include <mecab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// local define for frontier
#include "frontier.h"

void edit_input_text(char *);
int modify_text(char *, char *);
int read_text(char *,char *, char *);
int check_duplicate(char *,char *,int);
int mecab_analyze (char *); 
int omitted_word(char *);

int
check_duplicate(char *key_list,char *key_value,int key_numbers){
	int i;
    char (*wp)[MAX_KEY_LENGTH];

	wp = key_list;

	for(i = 0; i < key_numbers; i++,wp++){
		if(!strcmp((char *)wp,key_value))  // key exsist
			return(1);
	}
	strcpy((char *)wp,key_value);
	return(0);
}

void
edit_input_text(char *input_buff){
  int i;

  for(i = 0; input_buff[i] != '\0';i++){
	switch(input_buff[i]){
		case 0x0d:
		case 0x0a:
		case 0x21:
		case 0x22:
		case 0x23:
		case 0x24:
		case 0x25:
		case 0x26:
		case 0x27:
		case 0x28:
		case 0x29:
		case 0x2a:
		case 0x2b:
		case 0x2c:
		case 0x2d:
		case 0x2e:
		case 0x2f:
		case 0x3a:
		case 0x3b:
		case 0x3c:
		case 0x3d:
		case 0x3e:
		case 0x3f:
		case 0x5b:
		case 0x5c:
		case 0x5d:
		case 0x5e:
		case 0x5f:
		case 0x60:
		case 0x7b:
		case 0x7c:
		case 0x7d:
		case 0x7e:
		case 0x7f:
  			input_buff[i] = ' ';
	}
  }
}

int
modify_text(char *buff, char *edit_buff){
    char *op, *p;

	op = edit_buff;
	if(p = strstr(op, "http")){
		// original buffer の何番目か？
		memcpy(buff, op, p - op);
		for(; *p; p++){
			if(*p == ' '){
				strcat(buff,p);
				return(0);
			}
		}
	}else{
		strcpy(buff,edit_buff);
		return(-1);
	}
}

int
read_text(char *file_name,char *input_buff, char *title_buff){
	FILE *fp;
  	char input_wk[MAX_TEXT_SIZE];

    if((fp = fopen(file_name,"r")) == NULL){
   		return(-1);
  	}
  	title_buff[0] ='\0';
	// read first line which is the Key in Wikipedia
  	if(fgets(input_wk,sizeof(input_wk),fp) != NULL){
		strcpy(title_buff,input_wk);
	}
  	input_buff[0] ='\0';
  	while(fgets(input_wk,sizeof(input_wk),fp) != NULL){
    	strcat(input_buff,input_wk);
  	}
  	fclose(fp);

	return(0);
}

int
omitted_word(char *key_word){
	char *wp;
	int k;

	wp = key_word;
	if(!strcmp(key_word,"RT"))
		return(-1);
	else if(!strcmp(key_word,"QT"))
		return(-1);
	else if(!strcmp(key_word,"．"))
		return(-1);
	else if(!strncmp(key_word,"www",3))
		return(-1);
	else if(!strncmp(key_word,"WWW",3))
		return(-1);
	else if(!strncmp(key_word,"ＷＷＷ",3))
		return(-1);

	// check number 
	for( k = 0; *wp; *wp ++){
		if((*wp >= '0') & (*wp <= '9')){
			k++;
		}
	}
	// all numbers(ASCII)
	if(strlen(key_word) == k){
		return(-1);
	}


/*
	if(!strcmp(key_word, "０"))
		return(-1);
	else if(!strcmp(key_word, "１"))
		return(-1);
	else if(!strcmp(key_word, "２"))
		return(-1);
	else if(!strcmp(key_word, "３"))
		return(-1);
	else if(!strcmp(key_word, "４"))
		return(-1);
	else if(!strcmp(key_word, "５"))
		return(-1);
	else if(!strcmp(key_word, "６"))
		return(-1);
	else if(!strcmp(key_word, "７"))
		return(-1);
	else if(!strcmp(key_word, "８"))
		return(-1);
	else if(!strcmp(key_word, "９"))
		return(-1);
	else if(!strcmp(key_word, "ー"))
		return(-1);
	else if(!strcmp(key_word, "・"))
		return(-1);
*/
	return(0);
}

#ifdef UNIT_TEST
main(int argc, char **argv){
char input_file[128];
strcpy(input_file,argv[1]);

#else
int
mecab_analyze (char *input_file){
#endif
	char input[MAX_TEXT_SIZE];
	char analyzed_text[MAX_TEXT_SIZE];
	char wk_buff[MAX_TEXT_SIZE];
	char wk_file_name[256];
	char title_buff[256];
	mecab_t *mecab;
	const mecab_node_t *node;
	FILE *wfp;
	char surface_buff[256];
	char key_list[MAX_KEY_NUMBERS][MAX_KEY_LENGTH];
	int key_numbers;

	strcpy(wk_file_name,TO_MECAB_FILE_DIR);
	strcat(wk_file_name,input_file);
	if(read_text(wk_file_name,input,title_buff)){
    	fprintf(stderr,"[%s] not found\n",wk_file_name);
		return(-1);
	}
	/****
	 remove(wk_file_name);
	****/
    // edit character e.g. ' '' { 0x0a
	edit_input_text(input);

	/**
	memset(analyzed_text,'\0',sizeof(analyzed_text));
	if(!modify_text(analyzed_text,input)){
		strcpy(wk_buff,analyzed_text);
		while(1){
			memset(analyzed_text,'\0',sizeof(analyzed_text));
			if(modify_text(analyzed_text,wk_buff))
				break;
			strcpy(wk_buff,analyzed_text);
		}
	}
	**/

	strcpy(wk_file_name,TO_HIBARI_FILE_DIR);
	strcat(wk_file_name,input_file);
  	if((wfp = fopen(wk_file_name,"w")) == NULL){
   		fprintf(stderr,"[%s] could not open\n",wk_file_name);
   		return(-1);
  	}
	/*
	fprintf(wfp,"{\"%s\"}.\n",input); // first write message
	*/
	fprintf(wfp,"{\"%s\"}.\n",title_buff); // write wiki title

  	mecab = mecab_new2("");
  	CHECK(mecab);

  	mecab_set_lattice_level(mecab, 0);   
  	// mecab_set_lattice_level(mecab, 1);   

  	node = mecab_sparse_tonode(mecab, input);
  	CHECK(node);
  	memset(key_list,'\0',sizeof(key_list));
  	for (key_numbers=0;  node; node = node->next) {
      	strncpy(surface_buff,node->surface,node->length);
      	surface_buff[node->length] ='\0';
#ifdef UNIT_TEST
		printf("名詞:[%s] 文字種:[%d] ID:[%d]\n",surface_buff,node->char_type,node->posid);
#endif
      	if (node->length <= 1)
			continue;
		if (omitted_word(surface_buff))
			continue;
      // check charcter type
    	switch(node->posid){
			case 3:  //記号
			case 4:  //数字
			case 5:  //記号
			case 6:  //記号
			case 7:  //記号
       	      	break;
			case 36: // '
			case 37:
			case 38:
			case 39:
			case 40:
			case 41:
			case 42:
			case 43:
			case 44:
			case 45:
			case 46:
			case 47:
			case 48:
			case 49:
			case 50:
			case 51:
			case 52:
			case 53:
			case 54:
			case 55:
			case 56:
			case 57:
			case 58:
			case 59:
			case 60:
			case 67:
	    		if(!check_duplicate((char *)key_list,surface_buff,key_numbers)){
					fprintf(wfp,"{\"%s\"}.\n",surface_buff);
					key_numbers ++;
				}
          		break;
			case 61: // 非自立　名詞
			case 62:
			case 63:
			case 64:
			case 65:
			case 66:
          		break;
        	default:
				//		printf("[%s] ID:[%d]\n",surface_buff,node->posid);
          		break;
    	}

#ifdef NOT_USE
    printf(" %s %d %d %d %d posid:[%d] %d %d %d %f %f %f %ld\n",
	   node->feature,
	   (int)(node->surface - input),
	   (int)(node->surface - input + node->length),
	   node->rcAttr,
	   node->lcAttr,
	   node->posid,
	   (int)node->char_type,
	   (int)node->stat,
	   (int)node->isbest,
	   node->alpha,
	   node->beta,
	   node->prob,
	   node->cost);
#endif
  	}
  	fclose(wfp);
  	mecab_destroy(mecab);
   
  	return 0;
}
