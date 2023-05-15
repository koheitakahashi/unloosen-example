require "unloosen"

class Utils
  def self.build_js_object(**kwargs)
    # This is workaround: in popup, JS.eval cannot be used.
    object = JS.global[:Object].call(:call)

    kwargs.each do |(key, value)|
      object[key] = value
    end

    object
  end
end

content_script site: "www.example.com" do
  h1 = document.querySelector("h1")
  h1.innerText = "Hello unloosen!"
  existed_div = document.querySelector("div")
  p_element = document.createElement('p')

  chrome.runtime.onMessage.addListener do |message|
    new_text_element = document.createTextNode(message)
    p_element.appendChild(new_text_element)
    existed_div.appendChild(p_element)

    true
  end
end

popup do
  submit_button = document.querySelector("button#submit")
  submit_button.addEventListener "click" do |e|
    form_text = document.querySelector("input#input").value

    query_object = Utils.build_js_object(active: true, currentWindow: true)
    chrome.tabs.query(query_object) do |tabs|
      tab = tabs.at(0)

      chrome.tabs.sendMessage(
        tab[:id],
        form_text,
      )
    end

    e.preventDefault
  end
end
