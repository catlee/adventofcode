#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"
require "matrix"

SAMPLE_REPORT = <<~SAMPLE
--- scanner 0 ---
404,-588,-901
528,-643,409
-838,591,734
390,-675,-793
-537,-823,-458
-485,-357,347
-345,-311,381
-661,-816,-575
-876,649,763
-618,-824,-621
553,345,-567
474,580,667
-447,-329,318
-584,868,-557
544,-627,-890
564,392,-477
455,729,728
-892,524,684
-689,845,-530
423,-701,434
7,-33,-71
630,319,-379
443,580,662
-789,900,-551
459,-707,401

--- scanner 1 ---
  686,422,578
605,423,415
515,917,-361
-336,658,858
95,138,22
-476,619,847
-340,-569,-846
567,-361,727
-460,603,-452
669,-402,600
729,430,532
-500,-761,534
-322,571,750
-466,-666,-811
-429,-592,574
-355,545,-477
703,-491,-529
-328,-685,520
413,935,-424
-391,539,-444
586,-435,557
-364,-763,-893
807,-499,-711
755,-354,-619
553,889,-390

--- scanner 2 ---
649,640,665
682,-795,504
-784,533,-524
-644,584,-595
-588,-843,648
-30,6,44
-674,560,763
500,723,-460
609,671,-379
-555,-800,653
-675,-892,-343
697,-426,-610
578,704,681
493,664,-388
-671,-858,530
-667,343,800
571,-461,-707
-138,-166,112
-889,563,-600
646,-828,498
640,759,510
-630,509,768
-681,-892,-333
673,-379,-804
-742,-814,-386
577,-820,562

--- scanner 3 ---
-589,542,597
605,-692,669
-500,565,-823
-660,373,557
-458,-679,-417
-488,449,543
-626,468,-788
338,-750,-386
528,-832,-391
562,-778,733
-938,-730,414
543,643,-506
-524,371,-870
407,773,750
-104,29,83
378,-903,-323
-778,-728,485
426,699,580
-438,-605,-362
-469,-447,-387
509,732,623
647,635,-688
-868,-804,481
614,-800,639
595,780,-596

--- scanner 4 ---
727,592,562
-293,-554,779
441,611,-461
-714,465,-776
-743,427,-804
-660,-479,-426
832,-632,460
927,-485,-438
408,393,-506
466,436,-512
110,16,151
-258,-428,682
-393,719,612
-211,-452,876
808,-476,-593
-575,615,604
-485,667,467
-680,325,-822
-627,-443,-432
872,-547,-609
833,512,582
807,604,487
839,-516,451
891,-625,532
-652,-548,-490
30,-46,-14
SAMPLE

Pos = Struct.new(:x, :y, :z) do
  def +(o)
    Pos.new(self.x + o.x, self.y + o.y, self.z + o.z)
  end

  def -(o)
    Pos.new(self.x - o.x, self.y - o.y, self.z - o.z)
  end

  def magnitude
    (x ** 2 + y ** 2 + z ** 2) ** 0.5
  end

  def transform(m)
    Pos.new(*(m * Matrix.column_vector([x, y, z])))
  end

  def <=>(o)
    [self.x, self.y, self.z] <=> [o.x, o.y, o.z]
  end
end

def parse_reports(input)
  report_lines = []
  reports = []
  scanner_id = nil
  input.lines.each do |line|
    if m = /--- scanner (\d+) ---/.match(line)
      unless report_lines.empty?
        r = ScannerReport.new(report_lines)
        reports << r
        report_lines = []
      end
      scanner_id = m[1]
    else
      report_lines << line
    end
  end
  unless report_lines.empty?
    r = ScannerReport.new(report_lines)
    reports << r
  end
  reports
end

class Scanner
  attr_accessor :pos, :beacons

  def initialize(initial_report)
    @pos = Pos.new(0, 0, 0)
    @facing = Pos.new(0, 0, 1)
    @up = Pos.new(0, 1, 0)
    @beacons = Set.new(initial_report.beacons)
  end

  def beacon_distances
    @beacons.to_a.combination(2).group_by do |b1, b2|
      (b1-b2).magnitude
    end
  end

  def merge_report(report)
    # Assume we're facing the same direction for now
    # Find an offset that we can use to shift all the becaons by
    my_becaon_distances = beacon_distances

    offset = nil
    report.beacon_distances.each do |d, pairs|
      unless pairs.length == 1
        puts "distance #{d} is ambiguous; skipping"
        next
      end
      if (my_pairs = my_becaon_distances[d]) && my_pairs.length == 1
        b1 = pairs.first.sort.first
        b2 = my_pairs.first.sort.first
        offset = b2-b1
        break
      end
    end

    unless offset
      puts "couldn't find offset"
      return false
    end

    puts "offset: #{offset}"

    report.beacons.each do |b|
      m = b + offset
      @beacons << m
    end
    return true
  end
end

class ScannerReport
  attr_reader :beacons

  def initialize(lines)
    @beacons = lines.map do |line|
      Pos.new(*line.split(",").map(&:to_i))
    end
  end

  def beacon_distances
    @beacons.combination(2).group_by do |b1, b2|
      (b1-b2).magnitude
    end
  end
end

class Day19 < Minitest::Test
  def test_pos
    p1 = Pos.new(0,2,0)
    p2 = Pos.new(4,1,0)

    p3 = p2 - p1

    assert_equal Pos.new(4,-1,0), p3
  end

  def test_magnitude
    assert_equal 1, Pos.new(1,0,0).magnitude
    assert_equal 2, Pos.new(2,0,0).magnitude
    assert_equal 2**0.5, Pos.new(1,1,0).magnitude
    assert_equal 3**0.5, Pos.new(1,1,1).magnitude
    assert_equal 3**0.5, Pos.new(1,-1,1).magnitude
  end

  def test_report
    r1 = ScannerReport.new(<<~SAMPLE.lines)
    0,2,0
    4,1,0
    3,3,0
    SAMPLE

    r2 = ScannerReport.new(<<~SAMPLE.lines)
    -1,-1,0
    -5,0,0
    -2,1,0
    SAMPLE

    assert_equal r1.beacon_distances.keys.sort, r2.beacon_distances.keys.sort

    s = Scanner.new(r1)
    s.merge_report(r2)
    assert_equal 3, s.beacons.length
  end

  def part1(input)
    reports = parse_reports(input)

    0
  end

  def test_part1_sample
    assert_equal 0, part1(SAMPLE_REPORT)
  end

  def test_part1
    assert_equal 0, part1(DAY19_text)
  end

  def part2(input)
    0
  end

  def test_part2_sample
    assert_equal 0, part2(SAMPLE_REPORT)
  end

  def test_part2
    assert_equal 0, part2(DAY19_text)
  end
end
