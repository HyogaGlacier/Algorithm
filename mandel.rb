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
	c = Array.new(h){ |i|
		Array.new(w){ |j|
			Complex(-2.1 + 2.7 * j / (w - 1), 1.35 - 2.7 * i / (h - 1))
		}
	}
	#z_0=0です。
	z = Array.new(h){ Array.new(w){ Complex(0.0, 0.0) } }
	#発散するスピードを取る配列です。infiniteやnanになった時が何回目の遷移かを記録します。
	#-1は発散しきらなかったことを示しています。nが十分大きいと仮定するので、この範囲は真っ黒にします。
	div = Array.new(h){ Array.new(w,-1) }
	#ここで発散をシミュレートします。
	n.times do |t|
		puts "t="+t.to_s
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
	#青と白の色で、それぞれグラデーション処理を行った後、合成を行って作ります。
	#取り敢えず両方の色を記録する配列を生成。初期値は真っ黒。
	blue = Array.new(h) { Array.new(w,0) }
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
	
	#div[i][j]!=-1の範囲を、(maxSpeed-div[i][j])/(maxSpeed-minSpeed)*0.5+0.5で着色。
	#発散した範囲を、黒（速い）〜青（遅い）、黒（発散しない）で着色します。
	for i in 0...h do
		for j in 0...w do
			if div[i][j]!=-1 then
				blue[i][j]=(maxSpeed-div[i][j]).to_f/(maxSpeed-minSpeed)
			end
		end
	end

	#グラデーションについて。
	#グラデーションは、あるマスの値を減衰させながら周囲のマスに浸透させる、というのを全てのマスに対して同時に行います。
	#「同時」と書きましたが、影響を与える際にそのマスは他のマスの影響を受けないよう、操作結果を別の配列に格納するだけです。
	puts "start:gradation"
	imageBlue=Array.new(h){Array.new(w,0)}
	for i in 0...h do
		for j in 0...w do

end

mandel(200,500,500)
