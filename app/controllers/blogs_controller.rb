# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_user_blog, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params.fetch(:term, '')).published.default_order
  end

  def show
    @blog = if user_signed_in?
              Blog.accessible_by_logged_in_user(current_user).find(params[:id])
            else
              Blog.published.find(params[:id])
            end
  end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_user_blog
    @blog = current_user.blogs.find(params[:id])
  end

  def blog_params
    attributes = %i[title content secret]
    attributes.push(:random_eyecatch) if current_user.premium?

    params.require(:blog).permit(attributes)
  end
end
