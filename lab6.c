#include <stdio.h>
#include <conio.h>

#define SPACES_PER_COLUMN 12

int main()
{
	int i;

	// clear screen
	clrscr();

    printf("Enter a digit between 0 and 9: ");
    

    char input = getch();
    if (input < '0' || input > '9') {
        printf("Invalid input '%c'.\nUsage: enter a digit between 0 and 9\n", input);
        exit(1);
    }
    
    clrscr();
    
    int num_columns = input - '0';
    
    for (int line = 1; line <= 10; line++) {
        gotoxy(1, line);
        printf("Line # %d", line);
        for (int column = 1; column <= num_columns; column++) {
            gotoxy(SPACES_PER_COLUMN * column, line);
            printf("column #%d", column);
        }
    }



	return 0;
}