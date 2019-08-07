# frozen_string_literal: true

class BlogPolicy < GraphQL::Api::Policy
  def read?(*)
    !user.nil?
  end

  def destroy?(*)
    !user.nil?
  end

  def create?(*)
    !user.nil?
  end

  def update?(*)
    !user.nil?
  end

  def access_field?(_object, field)
    field.to_sym != :name
  end
end
