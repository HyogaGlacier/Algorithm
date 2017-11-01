=begin
マンデルブロ集合を出力します。ここではマンデルブロ集合については一切解説しません。
引数
n:繰り返し処理を行う回数。あまり回数が少ないと判定がうまく行きません。
h:画像の高さ。h>=2が条件です。100以上を推奨します
w:画像の幅。w>=2が条件です。100以上を推奨します
正方形の範囲をw×hに分割して出力します。そのため、使用時はh=wが望ましいです。
n,h,wについてはまずいものを入れた時に回避できるよう注意していますが、念の為自然数を引数として取るようにお願いします。逆に、この方法を回避できるものがあれば教えてください。
参考URL(rubyのドキュメントを除く)
https://ja.wikipedia.org/wiki/%E3%83%9E%E3%83%B3%E3%83%87%E3%83%AB%E3%83%96%E3%83%AD%E9%9B%86%E5%90%88
=end
require 'complex'
require 'benchmark'

def dist(dx,dy,w,h)
	return ((dx.to_f/w)**2+(dy.to_f/h)**2)**0.5
end

def mandel(n = 500, h = 600, w = 600)
	#n,h,wが自然数かどうか判定します。変数を文字列にキャストし、正規表現で落としています。
	if (/^\d+$/ =~ n.to_s).nil? || (/^\d+$/ =~ h.to_s).nil? || (/^\d+$/ =~ w.to_s).nil? then
		puts "Error:Please set n,h,w to integer."
		return
	end
	#h,w>=2で無いと0除算で死んだりするので、ここで処理します。
	if h < 2 || w < 2 then
		puts "Error:Please set h,w>=2."
		return
	end

	#初期値を設定します。
	#c[i][j]=Complex(-2.0+4.0*i/(h-1),2.0-4.0*j/(w-1))
	#(i,j)=(0,0)が(x,y)=(-2.7,1.35)、(i,j)=(w-1,h-1)が(x,y)=(0.6,-1.35)として分割します
	l=2.7
	c = Array.new(h){ |i|
		Array.new(w){ |j|
			Complex(-l + 0.6 + l * j / (w - 1), l / 2 - l * i / (h - 1))
		}
	}
	#z_0=0です。
	z = Array.new(h){ Array.new(w){ Complex(0.0, 0.0) } }
	#発散するスピードを取る配列です。infiniteやnanになった時が何回目の遷移かを記録します。
	#-1は発散しきらなかったことを示しています。nが十分大きいと仮定するので、この範囲は真っ黒にします。
	div = Array.new(h){ Array.new(w,-1) }
	#ここで発散をシミュレートします。
	n.times do |t|
		#puts "t="+t.to_s
		for i in 0...h do
			for j in 0...w do
				#z_nが既にinfiniteかnanならこれ以上計算しません。
				if z[i][j].abs.finite? then
					#漸化式は　z_(n+1)=z_n^2+c　です。
					z[i][j] = z[i][j]**2 + c[i][j]
					#zがinfiniteかnanになったならdivに今のtを記録します。
					if z[i][j].abs.finite?.! then
						div[i][j]=t
					end
				end
			end
		end
	end

	#着色について。
	#白色で、グラデーション処理を行った後、背景を青にして合成を行って作ります。
	#取り敢えず色を記録する配列を生成。初期値は真っ黒。
	white = Array.new(h) { Array.new(w,0) }
	#「発散した」=「zがfiniteでなくなった」として、そのタイミングで発散速度を考えます。
	minSpeed=Float::INFINITY
	maxSpeed=0.0
	#ここで、divは発散速度が速いほど小さくなる（分かりづらい）ので、値を調整します。
	for i in 0...h do
		for j in 0...w do
			if div[i][j]!=-1 then
				div[i][j]=(n-div[i][j])**2
				minSpeed=[minSpeed,div[i][j]].min
				maxSpeed=[maxSpeed,div[i][j]].max
			end
		end
	end

	#青色の着色
	#div[i][j]!=-1の範囲を、(maxSpeed-div[i][j])/(maxSpeed-minSpeed)*0.5+0.5で着色。
	#発散した範囲を、黒（速い）〜青（遅い）、黒（発散しない）で着色します。
	for i in 0...h do
		for j in 0...w do
			#p [i,j]
			if div[i][j]!=-1 then
				white[i][j]=(maxSpeed-div[i][j]).to_f/(maxSpeed-minSpeed)
			end
		end
	end
	#グラデーションを行います。そのマス+8近傍の平均です。
	rep=[h,w].max.div(100)
	rep.times{
		bw=white
		white=Array.new(h){Array.new(w,0.0)}
		for i in 0...h do
			for j in 0...w do
				if div[i][j]==-1 then
					next
				end
				cnt=0
				for y in i-1..i+1 do
					for x in j-1..j+1 do
						if y<0||h<=y||x<0||w<=x then
							next
						end
						if div[y][x]==-1 then
							next
						end
						cnt+=1
						white[i][j]+=bw[y][x]
					end
				end
				white[i][j]/=cnt.to_f
			end
		end
	}

	#合成。背景は[0,0,0.2]
	image=Array.new(h){Array.new(w){[0,0,0.1]}}
	for i in 0...h do
		for j in 0...w do
			if div[i][j]==-1 then
				image[i][j]=[0,0,0]
			else
				image[i][j]=[white[i][j],white[i][j],[1.0,image[i][j][2]+white[i][j]].min]
			end
		end
	end
	show(image)
end

#時間計測の際はコメントを外してください。
#result=Benchmark.realtime do
	mandel(200,500,500)
#end
#puts "used times: #{result}s"
