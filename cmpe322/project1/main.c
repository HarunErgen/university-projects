#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>

// global variables
size_t max_byte = 512;	// max size to be allocated
char *history[15] = {0};	// history array

// prototypes
int execute_cmd(char* cmd, char *args[], char* cmd_args);
int create_process(char* path, char* arguments);
char** parse_cmd(char* cmd);
int remove_char(char *str, char rem);
int add_history(char *cmd);
int search_history(char *cmd);

int main(int argc, char** argv) {
	char* user = getenv("USER");			// get username
	char *buf = malloc(sizeof(char) * max_byte);	// allocate space for buffer
	char** parsed_arr;				// "command arg1 arg2.."" parsed and put into parsed_arr as ["cmd", "arg1", ...]
	char* cmd;					// command
	char *args[sizeof(char*) * max_byte];		// arguments
	
	// program loop				
	while(1) {
		printf("%s >>> ", user);		// prints username at the beginning	
		getline(&buf, &max_byte, stdin);	// gets input into buffer
		parsed_arr = parse_cmd(buf);		// parse buffer
		cmd = parsed_arr[0];			// first element of array is the command
		
		int i = 1;
		for(; parsed_arr[i] != NULL; i++) {
			args[i-1] = parsed_arr[i];	// put all arguments into args
		}
		remove_char(cmd, '\n');			// remove newline from the command
		args[i-1] = NULL;			// put NULL at the end of args 
		
		// put command and args into a single string
		char *_cmd_args = (char *)malloc(max_byte * sizeof(char));
		strcpy(_cmd_args, cmd);
		for(int i = 0; args[i] != NULL; i++) {
			strcat(_cmd_args, " ");			
			strcat(_cmd_args, args[i]);
		}
		strcat(_cmd_args, "\0");
		remove_char(_cmd_args, '\n');
		remove_char(_cmd_args, '"');
		
		// put args into single string
		char *_args = (char *)malloc(max_byte * sizeof(char));
		for(int i = 0; args[i] != NULL; i++) {
			if(i==0) {
				strcpy(_args, args[i]);
				continue;			
			}	
			strcat(_args, " ");			
			strcat(_args, args[i]);
		}
		strcat(_args, "\0");
		remove_char(_args, '\n');
		

		execute_cmd(cmd, args, _args);	// execution of command with args
		add_history(_cmd_args);		// add command with args to history
	}
	// free allocated memories
	free(user);
	free(buf);
	free(parsed_arr);
	free(cmd);
	return 0;
}

int execute_cmd(char *cmd, char *args[], char *_args) {
	if (strcmp(cmd, "listdir") == 0) {		// create child process to execute "ls"	
		char* path = "/bin/ls";		
		create_process(path, NULL);
	}
	if (strcmp(cmd, "mycomputername") == 0) {	// create child process to execute "hostname"
		char* path = "/bin/hostname";		
		create_process(path, NULL);
	}
	if (strcmp(cmd, "whatsmyip") == 0) {		// create child process to execute "hostname -I"
		char* path = "/bin/hostname";		
		create_process(path, "-I");
	}
	if (strcmp(cmd, "printfile") == 0) {		
		int args_len = -1;			// number of args given
		while(args[++args_len] != NULL);	

		char *ifile_name = args[0];		// first arg is input filename
		remove_char(ifile_name, '"');		// remove quoting marks		
		remove_char(ifile_name, '\n');		// remove newline at the end 
		FILE *ifile = fopen(ifile_name, "r");	// open input file
		
		if (ifile == NULL) {
			perror("Error opening file\n");
			exit(1);
		}
		
		char **content;				// content of the file
		content = malloc(sizeof(char*));	// allocate space for pointer to pointer
		*content = malloc(sizeof(char));	// allocate space for pointer to char
		char ch;				// characters of the file
		int i = 0;				// index of pointer to pointer
		int j = 0;				// index of pointer to char
		
		while((ch = fgetc(ifile)) != EOF) {
			if(ch == '\n') {
				content[i][j] = '\0';
				j = 0;
				content = realloc(content, sizeof(char*) * (++i+1));	// increment space for next char* content is pointing
				content[i] = malloc(sizeof(char));			// increment space for the first char content[i] is pointing
				continue;	
			}
			content[i] = realloc(content[i], sizeof(char) * (j+2));	// increment space for next char content[i] is pointing
			content[i][j] = ch;					// write the char at content -> content[i] -> content[i][j]
			j++;		
		}
		// NULL at the end of the content
		content[i] = realloc(content[i], sizeof(char) * (j+2));	// increment space for NULL
		content[i][j] = '\0';					// put NULL at the end
		fclose(ifile);
		
		// if there is 1 argument, then print input file
		if (args_len == 1) {
			char *fpbuf = malloc(sizeof(char) * max_byte);	// dummy file print buffer
			int file_len = i;
			while(i >= 0) {
				printf("%s", content[file_len - i--]);
				while(1) {
					getline(&fpbuf, &max_byte, stdin); // pressing enter detection
					break;	
				}
			}
			
			return 0;
		}
		// if there is more than 1 argument, then write input file into the output file
		else if (args_len > 1) {
			char *ofile_name = args[2];		// third arg is output filename
			remove_char(ofile_name, '\n');			
			FILE *ofile = fopen(ofile_name, "w");	// open output file
			int file_len = i;

			while(i >= 0) {
				if(i!=0)
					fprintf(ofile, "%s\n", content[file_len - i--]);
				else
					fprintf(ofile, "%s", content[file_len - i--]);
			}
	
			fclose(ofile);
			return 0;
		}
	}
	if (strcmp(cmd, "dididothat") == 0) {
		char *search = _args;		// search = args
		remove_char(search, '"');	// remove quoting marks
		remove_char(search, '\n');	// remove new lines
		if(search_history(search)) {
			printf("Yes\n");
		}
		else {
			printf("No\n");		
		}
	}
	if (strcmp(cmd, "hellotext") == 0) {
		system("${EDITOR:-${gedit:-vi}}");	// env var EDITOR -> gedit -> vi
	}
	if (strcmp(cmd, "exit") == 0) {
		exit(0);	// exit with 0
	}
	return 1;
}

int create_process(char* path, char* arguments) {
	pid_t pid;
	char *argv[] = {path, arguments, NULL};
	pid = fork();
	if (pid < 0) {		// Child creation error
		perror("Child is not created\n");
	}
	if (pid == 0) {		// Child process
		int ret_val = execve(argv[0], argv, NULL);		
	}
	else {			// Parent process
		wait(NULL);	// Parent waits its children
		return 0;
	}
	return 1;
}

char** parse_cmd(char* cmd) {
	char* delim = " ";
	char* copy = malloc(sizeof(char) * strlen(cmd));	// allocation for copy
	copy = strcpy(copy, cmd);				// copy cmd to the copy string
	char** parsed_arr = malloc(0);				// dynamic allocation for parsed_arr
	char* tok = strtok(copy, delim);			// delimit by whitespace
	int size = 0;
	while(tok) {
		parsed_arr = realloc(parsed_arr, sizeof(char*) * ++size);	// increase size for new string
		parsed_arr[size-1] = tok;
		tok = strtok(NULL, delim);
	}
	// put null at the end
	parsed_arr = realloc(parsed_arr, sizeof(char*) * (size+1));
	parsed_arr[size] = NULL;
	return parsed_arr;
}

int remove_char(char *str, char rem) {
	char *src, *dest;
	for(src = dest = str; *src != '\0'; src++) {	// increase pointer until NULL
		*dest = *src;
		if(*dest != rem) {			// skip the char to be removed
			dest++;		
		}
	}
	*dest = '\0';
	return 1;
}

int add_history(char *cmd) {
	for(int i = 14; i>=0; i--) {
		history[i+1] = history[i];	 // shift array to the right
	}
	history[0] = cmd;			 // insert command at the beginning of the history
	return 1;
}

int search_history(char *cmd) {	
	for(int i = 0; i<15; i++) {
		if(history[i] != NULL && strcmp(cmd, history[i]) == 0) {
			return 1;	// if exists, return 1
		}
	}
	return 0;
}
