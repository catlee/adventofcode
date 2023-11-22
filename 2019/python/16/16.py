#!/usr/bin/env python

def tostr(l):
    return "".join(str(i) for i in l)

def fft(in_, offset=0):
    if isinstance(in_, str):
        in_ = [int(i) for i in in_]
    n = len(in_)
    out = [0] * n
    if offset > n // 2:
        last = 0
        for i in range(n-1, offset-1, -1):
            out[i] = (in_[i] + last) % 10
            last = out[i]
        return out

    for i in range(offset, n):
        # We have (i+1) zeros, followed by (i+1) 1's
        # We need to add in_[i+1..(2i + 2)]
        # Then another (i+1) zeros, followed by (i+1) -1s
        j = i
        while j < n:
            m = min(n, j+i+1)
            if (j % (4*(i+1))) < (3*i) + 2:
                #print("+", i, [in_[k] for k in range(j, m)])
                out[i] += sum(in_[k] for k in range(j, m))
                j += 2*(i + 1)
            else:
                #print("-", i, [in_[k] for k in range(j, m)])
                out[i] -= sum(in_[k] for k in range(j, m))
                j += 2*(i + 1)

        out[i] = abs(out[i]) % 10

    return out


def fftn(in_, n, offset=0):
    rv = in_
    for i in range(n):
        rv = fft(rv, offset)
    return rv[offset:offset+8]


assert tostr(fft("12345678")) == "48226158"
assert tostr(fft("48226158")) == "34040438"
assert tostr(fft("34040438")) == "03415518"
assert tostr(fft("03415518")) == "01029498"

assert tostr(fft("03415518", 0)) == "01029498"
assert tostr(fft("03415518", 2)) == "00029498"
assert tostr(fft("03415518", 4)) == "00009498"
assert tostr(fft("03415518", 6)) == "00000098"

assert tostr(fftn("12345678", 4)) == "01029498"

assert tostr(fftn("69317163492948606335995924319873", 100, 0)) == "52432133"
assert tostr(fftn("19617804207202209144916044189917", 100, 0))== "73745418"
assert tostr(fftn("80871224585914546619083218645595", 100, 0)) == "24176176"

s = "59767332893712499303507927392492799842280949032647447943708128134759829623432979665638627748828769901459920331809324277257783559980682773005090812015194705678044494427656694450683470894204458322512685463108677297931475224644120088044241514984501801055776621459006306355191173838028818541852472766531691447716699929369254367590657434009446852446382913299030985023252085192396763168288943696868044543275244584834495762182333696287306000879305760028716584659188511036134905935090284404044065551054821920696749822628998776535580685208350672371545812292776910208462128008216282210434666822690603370151291219895209312686939242854295497457769408869210686246"

assert tostr(fftn(s, 100)) == "74369033"

#assert fftn("03036732577212944063491565474664" * 10000, 100, 303673) == "84462026"

s *= 10000
print(tostr(fftn(s, 100, int(s[:7]))))
