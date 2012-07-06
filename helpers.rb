require 'rdiscount'

helpers do
  
  def get_ip
    forwarded = request.env['HTTP_X_FORWARDED_FOR']
    forwarded.present? ? forwarded.split(',').first : nil
  end
  
  def admin?
    session[:admin] == true
  end
  
  def paginate(per_page, criteria)
    page = (params[:page]).to_i || 1
    page = 1 if page < 1
    
    [
      criteria.skip((page-1) * per_page).limit(per_page).to_a,
      page
    ]
  end
  
  def previous_page?(documents, page, per_page)
    page > 1
  end
  
  def next_page?(documents, page, per_page)
    documents.size == per_page
  end
  
  def post_path(post)
    "/post/#{post.slug}"
  end
  
  def comment_path(post)
    "#{post_path post}/comments"
  end
  
  def h(text)
    Rack::Utils.escape_html(text)
  end
  
  def short_datetime(time)
    time.strftime "%Y-%m-%d"
  end
  
  def long_datetime(time)
    time.xmlschema
  end
  
  def short_date(time)
    time.strftime "%b #{time.day}" # remove 0-prefix
  end
  
  def long_date(time)
    time.strftime "%B #{time.day}, %Y" # remove 0-prefix
  end
  
  def rss_date(time)
    time.strftime "%a, %d %b %Y %H:%M:%S %T"
  end
  
  def comment_time(time)
    # Aug 21, 12:03pm
    meridian = time.strftime "%p"
    hour = time.strftime "%I"
    day = time.strftime "%d"
    time.strftime "%b #{day.to_i}, #{hour.to_i}:%M#{meridian.downcase}"
  end
  
  def post_header(post)
    partial "header", :engine => :erb, :locals => {post: post}
  end

  def post_body(post)
    render_songs RDiscount.new(post.body).to_html, post.slug
  end
  
  def comment_body(body)
    RDiscount.new(body, :filter_html, :autolink).to_html
  end
  
  def meta_description(post)
    post_body(post).gsub "\"", "&quot;"
  end
  
  def form_escape(string)
    string ? string.gsub("\"", "&quot;") : nil
  end
  
  def url_escape(url)
    URI.escape url
  end
  
  def render_songs(body, slug)
    body.gsub /(?:<p>\s*)?\[song "([^"]+)"\].*?\[name\](.*?)\[\/name\].*?\[by(?: "([^"]+)")?\](.*?)\[\/by\].*?\[\/song\](?:\s*<\/p>)?/im do
      partial "song", :engine => :erb, :locals => {
        :filename => $1,
        :name => $2,
        :link => $3,
        :by => $4,
        :slug => slug
      }
    end
  end
end