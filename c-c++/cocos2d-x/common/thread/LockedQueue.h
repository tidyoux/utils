//
//  LockedQueue.h
//  
//
//  on 15-5-14.
//
//

#ifndef _LockedQueue_h
#define _LockedQueue_h

#include <deque>
#include <thread>
#include <mutex>
#include <functional>

template<class T>
class LockedQueue
{
public:
    void pushBack(const T &data)
    {
        lock();
        m_queue.push_back(data);
        unlock();
    }
    
    void pushFront(const T &data)
    {
        lock();
        m_queue.push_front(data);
        unlock();
    }
    
    bool pickFront(T &data)
    {
        lock();
        if (m_queue.empty())
        {
            unlock();
            return false;
        }
        data = m_queue.front();
        m_queue.pop_front();
        unlock();
        return true;
    }
    
    // @warning remember calling unlock() after view!
    bool viewFront(T &data)
    {
        lock();
        if (m_queue.empty())
        {
            unlock();
            return false;
        }
        data = m_queue.front();
        return true;
    }
    
    void popFront()
    {
        lock();
        m_queue.pop_front();
        unlock();
    }
    
    void foreach(std::function<void(T &data)> visitor)
    {
        lock();
        for (auto v : m_queue)
        {
            visitor(v);
        }
        unlock();
    }
    
    void clear()
    {
        lock();
        m_queue.clear();
        unlock();
    }
    
    bool isEmpty()
    {
        bool ret = true;
        lock();
        ret = m_queue.empty();
        unlock();
        return ret;
    }
    
    size_t size()
    {
        size_t ret = 0;
        lock();
        ret = m_queue.size();
        unlock();
        return ret;
    }
    
    void lock()
    {
        m_mutex.lock();
    }
    
    void unlock()
    {
        m_mutex.unlock();
    }
private:
    std::deque<T> m_queue;
    std::mutex m_mutex;
};

#endif // _LockedQueue_h
