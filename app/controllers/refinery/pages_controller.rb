module Refinery
  class PagesController < ::ApplicationController
    include Pages::RenderOptions
    # Add post helper to home view
    helper Refinery::Blog::PostsHelper

    before_action :find_page, :set_canonical
    before_action :error_404, :unless => :current_user_can_view_page?

    # Save whole Page after delivery
    after_action :write_cache?

    # This action is usually accessed with the root path, normally '/'
    def home
      # Grab 50 posts so that you'll always have at loast 5 sports posts (hopefully)
      all_posts = Refinery::Blog::Post.where("published_at < ?", Time.now).limit(50)
      @posts = all_posts.reject { |p| p.categories.first && (p.categories.first.title == "Sports" || p.categories.first.title == "News") }
      @sports = all_posts.select { |p| p.categories.first && p.categories.first.title == "Sports" }
      @news = all_posts.select { |p| p.categories.first && p.categories.first.title == "News" }
      render_with_templates?
    end

    # This action can be accessed normally, or as nested pages.
    # Assuming a page named "mission" that is a child of "about",
    # you can access the pages with the following URLs:
    #
    #   GET /pages/about
    #   GET /about
    #
    #   GET /pages/mission
    #   GET /about/mission
    #
    def show
      if should_skip_to_first_child?
        redirect_to refinery.url_for(first_live_child.url) and return
      elsif page.link_url.present?
        redirect_to page.link_url and return
      elsif should_redirect_to_friendly_url?
        redirect_to refinery.url_for(page.url), :status => 301 and return
      end

      render_with_templates?
    end

    def personalities
      @personalities = Refinery::User.all
      render_with_templates?
    end

    def sports
      posts = Refinery::Blog::Post.all
      @sports = posts.select { |p| p.categories.first && p.categories.first.title == "Sports" }
      render_with_templates?
    end

    def news
      posts = Refinery::Blog::Post.all
      @newss = posts.select { |p| p.categories.first && p.categories.first.title == "News" }
      render_with_templates?
    end

    def shows
      @shows = Refinery::Blog::Category.where.not(title: "Sports").where.not(title: "WVBR")
      render_with_templates?
    end

  protected

    def requested_friendly_id
      if ::Refinery::Pages.scope_slug_by_parent
        # Pick out last path component, or id if present
        "#{params[:path]}/#{params[:id]}".split('/').last
      else
        # Remove leading and trailing slashes in path, but leave internal
        # ones for global slug scoping
        params[:path].to_s.gsub(%r{\A/+}, '').presence || params[:id]
      end
    end

    def should_skip_to_first_child?
      page.skip_to_first_child && first_live_child
    end

    def should_redirect_to_friendly_url?
      requested_friendly_id != page.friendly_id || ::Refinery::Pages.scope_slug_by_parent && params[:path].present? && params[:path].match(page.root.slug).nil?
    end

    def current_user_can_view_page?
      page.live? || current_refinery_user_can_access?("refinery_pages")
    end

    def current_refinery_user_can_access?(plugin)
      refinery_user? && current_refinery_user.authorized_plugins.include?(plugin)
    end

    def first_live_child
      page.children.order('lft ASC').live.first
    end

    def find_page(fallback_to_404 = true)
      @page ||= case action_name
                when "home"
                  Refinery::Page.where(:link_url => '/').first
                when "show"
                  Refinery::Page.find_by_path_or_id(params[:path], params[:id])
                when "personalities"
                  Refinery::Page.where(slug: 'personalities').first
                when "shows"
                  Refinery::Page.where(slug: 'shows').first
                when "sports"
                  Refinery::Page.where(slug: 'sports').first
                end
      @page || (error_404 if fallback_to_404)
    end

    alias_method :page, :find_page

    def set_canonical
      @canonical = refinery.url_for @page.canonical if @page.present?
    end

    def write_cache?
      if Refinery::Pages.cache_pages_full && !refinery_user?
        cache_page(response.body, File.join('', 'refinery', 'cache', 'pages', request.path).to_s)
      end
    end
  end
end
