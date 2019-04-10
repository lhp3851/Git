//
//  randomnumber.cpp
//  C-projects
//
//  Created by sumian on 2018/12/14.
//  Copyright © 2018 personal. All rights reserved.
//

#include "randomnumber.hpp"

void getRandom(){
    int seed = 0;
    printf("input your total number:");
    scanf("%d",&seed);
    int a[20];
    int i,j;
    srand((int)time(0));
    a[0]=rand()%seed;
    for(i=1;i<seed;i++)
    {
        a[i]=rand()%seed;
        for(j=0;j<i;j++)
        {
            if(a[i]==a[j])
            {
                i--;
            }
        }
    }
    for(i=0;i<seed;i++)
    {
        printf("%3d\n",a[i]);
    }
}
