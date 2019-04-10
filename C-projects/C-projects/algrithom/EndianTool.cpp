//
//  EndianTool.cpp
//  C-projects
//
//  Created by sumian on 2019/4/10.
//  Copyright © 2019 personal. All rights reserved.
//

#include "EndianTool.hpp"

bool isBigEndian() {
    union w
    {
        int a;
        char b;
    } c;
    c.a = 1;
    if (c.b == 1) {
        return true;
    } else {
        return false;
    }
}
