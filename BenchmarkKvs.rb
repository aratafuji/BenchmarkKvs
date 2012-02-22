require 'rubygems'
require 'benchmark'
require 'memcached'
require 'memcache'
require 'redis'
require 'dalli'

class BenchmarkKvs
  attr_accessor :mc_mc, :mc_md, :mc_dl, :km_mc, :km_md, :km_dl, :rd
  BENCH_TIMES = 10000

  def initialize
    # Memcached(port:11211)
    @mc_mc = Memcache.new(:server => '127.0.0.1:11211')
    @mc_md = Memcached::new('127.0.0.1:11211')
    @mc_dl = Dalli::Client.new('127.0.0.1:11211')

    #Kumofs(port:11212)
    @km_mc = Memcache.new(:server => '127.0.0.1:11212')
#    @km_md = Memcached::new('127.0.0.1:11212')
#    @km_dl = Dalli::Client.new('127.0.0.1:11212')

    #Redis
    @rd = Redis.new
  end

  def set_bench (obj)
    1.upto BENCH_TIMES do |i|
      obj.set("foo_#{i}", "bar_#{i}")
    end
  end

  def get_bench (obj)
    1.upto BENCH_TIMES do |i|
      obj.get("foo_#{i}")
    end
  end

  def start
    Benchmark.bm do |b|
      # Memcached(memcache)
      if @mc_mc
        b.report("Memcached(memcache):set") {
          set_bench (@mc_mc)
        }
        b.report("Memcached(memcache):get") {
          get_bench (@mc_mc)
        }
      end

      # Memcached(memcached)
      if @mc_md
        b.report("Memcached(memcached):set") {
          set_bench (@mc_md)
        }
        b.report("Memcached(memcached):get") {
          get_bench (@mc_md)
        }
      end

      # Memcached(Dalli)
      if @mc_dl
        b.report("Memcached(Dalli):set") {
          set_bench (@mc_dl)
        }
        b.report("Memcached(Dalli):get") {
          get_bench (@mc_dl)
        }
      end

      # Kumofs(memcache)
      if @km_mc
        b.report("Kumofs(memcache):set") {
          set_bench (@km_mc)
        }
        b.report("Kumofs(memcache):get") {
          get_bench (@km_mc)
        }
      end

      # Kumofs(memcached)
      if @km_md
        b.report("Kumofs(memcached):set") {
          set_bench (@km_md)
        }
        b.report("Kumofs(memcached):get") {
          get_bench (@km_md)
        }
      end

      # Kumofs(Dalli)
      if @km_dl
        b.report("Kumofs(Dalli):set") {
          set_bench (@km_dl)
        }
        b.report("Kumofs(Dalli):get") {
          get_bench (@km_dl)
        }
      end

      # Redis
      if @rd
        b.report("Redis:set") {
          set_bench (@rd)
        }
        b.report("Redis:get") {
          get_bench (@rd)
        }
      end
    end
  end
end

(BenchmarkKvs.new).start
