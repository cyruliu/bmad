#include <stdio.h>
#include <string.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>


static void function(char *str, int len)
{
	char buf[16];

	//fprintf(stderr, "%08lx\n", (long)buf);
	printf(str);
	fflush(stdout);
	memcpy(buf, str, len);
}

static void error(char *msg)
{
	perror(msg);
	exit(1);
}

int main(int argc, const char **argv)
{
	char large_string[256];
	int sockfd, newsockfd, portno, r, c;
	struct sockaddr_in serv_addr, cli_addr;
	struct hostent *server;
	socklen_t clilen;

	if (argc < 3) {
		fprintf(stderr,"usage %s hostname port\n", argv[0]);
		exit(1);
	}

        server = gethostbyname(argv[1]);
        if (server == NULL) 
                fprintf(stderr,"ERROR, no such host\n");
        portno = atoi(argv[2]);
        sockfd = socket(AF_INET, SOCK_STREAM, 0);
        if (sockfd < 0)
                error("ERROR opening socket");

        memset(&serv_addr, 0, sizeof(serv_addr));
        serv_addr.sin_family = AF_INET;
        memcpy(server->h_addr, &serv_addr.sin_addr.s_addr, server->h_length);
        serv_addr.sin_port = htons(portno);

	r = bind(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr));
	if (r != 0)
	      error("ERROR on binding");
	r = listen(sockfd, 5);
	if (r != 0)
	      error("ERROR on listening");

	clilen = sizeof(cli_addr);
	newsockfd = accept(sockfd, (struct sockaddr *)&cli_addr, &clilen);
	if (newsockfd < 0) 
		error("ERROR on accept");

	fflush(stdout);
	newsockfd = dup2(newsockfd, 1);

	while (1) {
		for (c = 0; c < sizeof(large_string); c++) {
			r = read(newsockfd, large_string + c, 1);
			if (r != 1)
				return 0;
			if (large_string[c] == '\n')
				break;
		}
		large_string[c] = '\0';
		function(large_string, c);
		fprintf(stderr, "Message processed\n");
	}

	return 0;
}
