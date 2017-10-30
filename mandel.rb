=begin
マンデルブロ集合を出力します。ここではマンデルブロ集合については一切解説しません。
引数
n:繰り返し処理を行う回数。あまり回数が少ないと判定がうまく行きません。
h:画像の高さ。h>=2が条件です。
w:画像の幅。w>=2が条件です。
|x|,|y|<=2の範囲を、画像を分割して出力します。そのため、使用時はh=wが望ましいです。
n,h,wについては最大限注意していますが、念の為自然数を引数として取るようにお願いします。逆に、この方法を回避できるものがあれば教えてください。
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
	#(i,j)=(0,0)を(x,y)=(-2.1,1.35)に、(i,j)=(h-1,w-1)を(x,y)=(0.6,-1.35)に当てて、残りは均等になるようにマスを振っています。
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
				div[i][j]=(n-div[i][j])
				minSpeed=[minSpeed,div[i][j]].min
				maxSpeed=[maxSpeed,div[i][j]].max
			end
		end
	end

	#青色の着色
	#div[i][j]!=-1の範囲を、(maxSpeed-div[i][j])/(maxSpeed-minSpeed)*0.5+0.5で着色。
	#発散した範囲を、黒（速い）〜青（遅い）、黒（発散しない）で着色します。
	#と同時にグラデーションをつけます。範囲はそこを中心に0.1の円。
	for i in 0...h do
		for j in 0...w do
			#p [i,j]
			if div[i][j]!=-1 then
				v=(maxSpeed-div[i][j]).to_f/(maxSpeed-minSpeed)
				dx=w.div(25)
				dy=h.div(25)
				white[i][j]=v
				for y in -dy..dy do
					if i+y<0||h<=i+y then
						next
					end
					for x in -dx..dx do
						if 0<=j+x&&j+x<w then
							if dist(x,y,dx,dy)<=1&&div[i+y][j+x]!=-1 then
								white[i+y][j+x]+=v*dist(x,y,dx,dy)
							end
						end
					end
				end
			end
		end
	end
	show(white)

	#合成。背景は0x0005c=[0,0,0.36]
	image=Array.new(h){Array.new(w){[0,0,0.36]}}
	for i in 0...h do
		for j in 0...w do
			if div[i][j]==-1 then
				image[i][j]=[0,0,0]
			else
				image[i][j]=[white[i][j],white[i][j],[1.0,image[i][j][2]+white[i][j]].max]
			end
		end
	end
	show(image)
end

result=Benchmark.realtime do
	mandel(200,500,500)
end
puts "used times: #{result}s"
