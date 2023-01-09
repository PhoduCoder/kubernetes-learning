def make_logger(target):
    return logger

def logger(data):
        with open(target, 'a') as f:
            f.write(data + '\n')

foo_logger = make_logger('foo.txt') #foo.txt will be created if not there already
foo_logger('Hello')
foo_logger('World')