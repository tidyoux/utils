//
//  FileTools.h
//  
//
//  on 14-12-9.
//
//

#ifndef ____FileTools__
#define ____FileTools__

#include <string>
#include "Macros.h"

class FileTools
{
public:
    static int makeDir(const std::string &path);
    static int clearDir(const std::string &path);
    static int clearDir(const std::string &path, bool delFolder);
    
private:
    make_static_class(FileTools);
};

#endif /* defined(____FileTools__) */
