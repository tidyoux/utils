//
//  FileTools.cpp
//  
//
//  on 14-12-9.
//
//

#include "FileTools.h"
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>

int FileTools::makeDir(const std::string &path)
{
    if (!path.empty())
    {
        char tmp[1024];
        char *p = NULL;
        
        snprintf(tmp, sizeof(tmp),"%s", path.c_str());
        size_t len = strlen(tmp);
        if(tmp[len - 1] == '/')
        {
            tmp[len - 1] = 0;
        }
        
        int err = 0;
        for(p = tmp + 1; *p; p++)
        {
            if(*p == '/')
            {
                *p = 0;
                err = mkdir(tmp, S_IRWXU);
                *p = '/';
            }
        }
        
        err = mkdir(tmp, S_IRWXU);
        return err;
    }
    return 0;
}

int FileTools::clearDir(const std::string &path)
{
    return clearDir(path, true);
}

int FileTools::clearDir(const std::string &path, bool delFolder)
{
    DIR *d = opendir(path.c_str());
    size_t path_len = path.size();
    int r = -1;
    if (d)
    {
        struct dirent *p;
        r = 0;
        while (!r && (p=readdir(d)))
        {
            int r2 = -1;
            char *buf;
            size_t len;
            
            /* Skip the names "." and ".." as we don't want to recurse on them. */
            if (!strcmp(p->d_name, ".") || !strcmp(p->d_name, ".."))
            {
                continue;
            }
            
            len = path_len + strlen(p->d_name) + 2;
            buf = (char *)malloc(len);
            if (buf)
            {
                struct stat statbuf;
                snprintf(buf, len, "%s/%s", path.c_str(), p->d_name);
                if (!stat(buf, &statbuf))
                {
                    if (S_ISDIR(statbuf.st_mode)) // buff is a folder name
                    {
                        r2 = clearDir(buf, delFolder);
                    }
                    else // buff is a file name
                    {
                        r2 = unlink(buf);
                    }
                }
                free(buf);
            }
            r = r2;
        }
        closedir(d);
    }
    
    if (delFolder)
    {
        if (!r)
        {
            r = rmdir(path.c_str());
        }
    }
    
    return r;
}
