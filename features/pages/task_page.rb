require_relative 'test_page'

class TaskPage < TestPage
  def description
    scoped do
      find('.description').text
    end
  end

  def start_edit
    scoped do
      find('#task__edit').click
    end
  end

  def close
    scoped do
      find('#task__back').click
    end
  end

  def set_title task_title
    scoped do
      fill_in 'title', with: task_title
    end
  end

  def set_description description
    scoped do
      fill_in 'description', with: description
    end
  end

  def save_changes
    scoped do
      click_on 'Save'
    end
  end

  def title_has_focus?
    scoped do
      has_css?('#task__edit-form input[name="title"]:focus')
    end
  end

  def add_tag tag_name
    scoped do
      find('.multiselect').click
      find('.multiselect input').send_keys tag_name
      find('.multiselect input').send_keys [:enter, :escape]
    end
  end

  def tags
    scoped do
      find_all('.tags .tag').map(&:text)
    end
  end
end
