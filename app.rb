require 'sinatra'
require 'sinatra/reloader'
require 'nokogiri'
require 'rest-client'
require 'json'
require "csv"


get '/' do
    erb :index
end  

get '/webtoon' do
    # 내가 받아온 웹툰 데이터를 저장할 배열 생성
    toons = []
    
    # 웹툰 데이터를 받아올 url파악 및 요청 보내기
    url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/mon"
    result = RestClient.get(url) #result에 값들이 저장 + get인 이유는 GET방식으로 Request받기 때문 
    
    # 응답으로 온 내용(Json : 다음)을 해쉬형태로 받아오기
    webtoons = JSON.parse(result)
    
    # 해쉬에서 웹툰 리스트에 해당하는 부분 순환하기
    webtoons["data"].each do |toon|#data의 자료를 toon에 담아서 순환한다.  -> toon에는 data속 item 하나가 들어있다.
       # 웹툰 제목
       title = toon["title"]
       # 웹툰 이미지 주소
       image = toon["thumbnailImage2"]['url']
       # 웹툰 링크
       link = "http://webtoon.daum.net/webtoon/view/#{toon['nickname']}"
       # 필요한 부분을 분리해서 처음만든 배열에 push
       toons << {"title" => title, "image" => image, "link" => link}
    end    
    # 완성된 배열 중에서 3개의 웹툰만 랜덤 추출
    @daum_webtoon = toons.sample(3)
    erb :webtoon # 1. html
end    
  
   
get '/check_file' do
    unless File.file?('./webtoon.csv') # if not == unless  unless는 false가 나와야 실행이 된다.
        # 내가 받아온 웹툰 데이터를 저장할 배열 생성
        toons = []
    
        # 웹툰 데이터를 받아올 url파악 및 요청 보내기
        url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/mon"
        result = RestClient.get(url) #result에 값들이 저장 + get인 이유는 GET방식으로 Request받기 때문 
    
        # 응답으로 온 내용(Json : 다음)을 해쉬형태로 받아오기
        webtoons = JSON.parse(result)
    
        # 해쉬에서 웹툰 리스트에 해당하는 부분 순환하기
        webtoons["data"].each do |toon|#data의 자료를 toon에 담아서 순환한다.  -> toon에는 data속 item 하나가 들어있다.
            # 웹툰 제목
            title = toon["title"]
            # 웹툰 이미지 주소
            image = toon["thumbnailImage2"]['url']
            # 웹툰 링크
            link = "http://webtoon.daum.net/webtoon/view/#{toon['nickname']}"
            # 필요한 부분을 분리해서 처음만든 배열에 push
            toons << [ title, image, link]
        end    
        # CSV 파일을 새로 생성하는 코드
        CSV.open('./webtoon.csv','w+') do |row| 
            #크롤링한 웹툰 데이터를 CSV에 삽입
            toons.each_with_index do |toon, index|
                row << [index+1, toon[0], toon[1], toon[2]]
            end
        end    
        erb :check_file
    else
        # 존재하는 csv파일을 불러오는 코드
        @webtoons = []
        CSV.open('./webtoon.csv','r+').each do |row|
            @webtoons << row
        end
        erb :webtoons  # redirect가 아닌 erb를 쓴 이유는 저번시간에 설명??
    end
end


#get  '/board' do
get  '/board/:name' do    
    puts params[:name]
end


#nil은 비어있는 지를 물어보는 것