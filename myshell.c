//Eyal Haber 203786298

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include<sys/wait.h>
#include <string.h>

struct command_struct { //this struct will contain the command
    int pid;
    char* command[100];
    int len;
};

struct command_struct all_commands[100]; // global array for past executed commands
int current = 0; //  a counter for all executed commands

void add_to_list (char* command[], int pid, int size){ // add command to the global command array
    int i;
    for (i = 0; i < size; i++){
        char a [100];
        char p [50];
        strcpy(a,command[i]);
        if (i == 0){
            sprintf(p, "%d", pid); // convert int pid to str pid
            strcat(p, " ");
            strcat(p, a);
            all_commands[current].command[i]= strdup(p);
        }
        else all_commands[current].command[i]= strdup(a);
    }
    all_commands[current].pid = pid;
    all_commands[current].len = i;
    current++;
}

void history(){ // execute history
    int i;
    for (i =0; i< current; i++){ // for all commands in the array
        int status;
        pid_t this_pid;
        if (all_commands[i].pid == -1){
            this_pid = 0;
        }
        else this_pid = waitpid(all_commands[i].pid,&status,WNOHANG);

        int j;
        for (j = 0; j < all_commands[i].len; j++){ //print all commands
            printf("%s ",all_commands[i].command[j]);
        }
        printf("\n");

        fflush(stdout);

        if (all_commands[i].pid == -1){ // mark the last history command as last
            all_commands[i].pid = 1;
        }
    }
}

char previous_folder[100]; // global char which contain the previous dir

void cd(char* command , char* full_command[] ){ //execute cd
    if (strcmp(command,"-") !=0 ){ //if the command is not "cd -", update the previous folder before moving
        getcwd(previous_folder, sizeof(previous_folder));
    }
    char* divided_input[100]; //break the input by "/"
    char* token = strtok(command, "/");
    int i = 0;
    while (token != NULL) {
        divided_input[i] = token;
        token = strtok(NULL, "/");
        i++;
    }
    int j;
    for ( j = 0; j < i; ++j) { //for all divided input, check and execute
        if (strcmp(divided_input[j],"~") == 0){ // condition ~
            if (chdir(getenv("HOME"))!= 0){
                perror("{the name of the system call for example: fork} failed");
            }
        }
        else if (strcmp(divided_input[j],"/") == 0){ // condition /
            if (chdir(getenv("ROOT"))!= 0){
                perror("{the name of the system call for example: fork} failed");
            }
        }
        else if (strcmp(divided_input[j],"-") == 0){ // condition -
            if (chdir(previous_folder) != 0){
                perror("{the name of the system call for example: fork} failed");
            }
        }
        else if (chdir(divided_input[j])!=0){
            perror("{the name of the system call for example: fork} failed");
        }
    }
}

int foreground ( char* command[], int size) {
    int stat, waited;
    pid_t pid;
    int ret_code;
    pid = fork();

    if (pid == 0) {  // Child
        ret_code = execvp(command[0],command);
        if (ret_code == -1)
        {
            add_to_list(command, pid, size);
            exit(1);
        }
    }
    if (pid > 0) {
        {  // Parent
            wait(&stat);
            add_to_list(command, pid, size);
            return 1;
        }
    }
    if (pid == -1) {
        perror("{the name of the system call for example: fork} failed");
    }
    return -1;
}

int main() {
    getcwd(previous_folder, sizeof(previous_folder)); // initialize prev dir to current dir
    while (1) {
        char input[100];
        char *divided_input[100];
        printf("$ ");
        fflush(stdout);
        fgets(input, 100, stdin); // receive input from user
        char *token = strtok(input, " "); // break input by " "
        int i = 0;
        while (token != NULL) {
            divided_input[i] = token;
            i++;
            token = strtok(NULL, " ");
        }
        strtok(divided_input[i - 1], "\n");
        char* command[i + 1]; //create char* with size fitted to input
        int j;
        for ( j = 0; j < i; ++j) { // copy from divided input
            command[j] = divided_input[j];
        }
        command[i] = NULL; // make last char* NULL
        if (strcmp(command[0], "exit") == 0) {
            break;
        }

        else if (strcmp(command[0], "history") == 0) {
            history();
        }
        else if (strcmp(command[0], "cd") == 0) {
            if (i >=3 || i == 1){
                perror("{the name of the system call for example: fork} failed");
            }
            else cd(command[1] ,command);
        }
        foreground(command,i);
    }
    int i; // free memory
    for ( i = 0; i<current; i++){
        int j;
        for(j=0; j<100; j++){
            free(all_commands[i].command[j]);
        }
    }
    exit(0);
    return 0;
}
