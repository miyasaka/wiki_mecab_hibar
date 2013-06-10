#define MAX_CHILDREN 8         //set child process numbers
#define CHILD_SLEEP_TIME 100000

#define PID_FILE "/var/tmp/prefork.pid"
#define MESSAGE_FILE_DIR "/home/public/frontier/"  // file interface directory from frontier
#define TO_MECAB_FILE_DIR "/home/public/mecab/"    // -> mv rename and pass to meCab
#define TO_HIBARI_FILE_DIR "/home/public/hibari/"  // -> mv hibari
#define FRONTIER "fr_xxxx.dat" // frontier message file.prefix="fr_"

#define CALL_ENV "/home/miyasaka/project/hibari/hibari_get_set_script.es"
#define CALL_ESCRIPT "hibari_get_set_script.es"

#define CHECK(eval) if (! eval) { \
    fprintf (stderr, "Exception:%s\n", mecab_strerror (mecab)); \
	    mecab_destroy(mecab); \
		    return -1; }

#define MAX_TEXT_SIZE 16384
#define MAX_KEY_NUMBERS 1024
#define MAX_KEY_LENGTH  512

