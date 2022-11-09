#include <stdio.h>

typedef unsigned char FP;

void print(FP a)
{
    for(int i =7 ; i>= 0; i--)
    {
        putchar('0' + ((a>>i) & 1));
    }
}

FP sub(FP a, FP b)
{
    return a + (~b)+1;
}

FP sub_p(FP a, FP b)
{
    FP c = sub(a,b);
    putchar(' ');
    print(a);
    putchar('\n');
    putchar('-');
    print(b);
    putchar('\n');
    puts("---------");
    putchar(' ');
    print(c);
    putchar(10);
    return c;
}

int comp_FP(FP a, FP b)
{
    putchar('(');
    print(a);
    putchar(' ');
    putchar('>');
    putchar (' ');
    print(b);
    putchar(')');
    int r = a > b;
    if (r){printf(" - yes\n");} else {printf(" - no\n");}
    return r;
}



int main()
{
    FP B = 0x11;
    FP A = 0x80;
    int counter = 0;
    int iter = 0;
    int arr[100] = {0};
//    while((iter < 90) && (A !=0) )
//    {
//        printf("#%i:\n",iter);
//        if(comp_FP(A,B)) {A = (sub_p(A,B)<<1);arr[iter++] = 1; printf("A << 1\n");print(A); putchar(10);}
//        else {A <<= 1; printf("A << 1\n");print(A); putchar(10); counter++; arr[iter++]=0;}
//        //printf("comp_FP(B,A) -> %i\n",comp_FP(B,A));
//
//
//    }

    while((iter < 90) && (A !=0) )
    {
        if(A>B) {A = (sub(A,B)<<1);arr[iter++] = 1;}
        else {A <<= 1;counter++; arr[iter++]=0;}
    }


    printf("\n\n result = \n");
    for(int i =0; i<20; i++)
    {
        putchar(arr[i] + '0');
    }
    printf("\n\n result = \n");
    for(int i =0; i<17; i++)
    {
        if(arr[i] == 1)
        {
            printf("2^{-%i+a}+",i);
        }
    }
    putchar(10);
//    putchar(10);
//    putchar(10);
//    putchar(10);

//    for(int i =15; i >= 0; i--)
//    {
//        printf("if(~(");
//        for (int j =15; j>= i; j--)
//        {
//            printf(" A[%i] |",j);
//        }
//        printf(" ~A[%i]",i);
//        printf(")) begin V = 4'b; end\n");
//    }


    //printf("Hello, World!");
    return 0;
}
