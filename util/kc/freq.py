class FrequencyDatabase(dict):
    def __missing__(self, key):
        return 0
    
    def tally(self, key):
        return self[key]

    def inc(self, key):
        self[key] = self[key] + 1
        return self

    def dec(self, key):
        if(self[key] > 0):
            self[key] = self[key] - 1
        return self
