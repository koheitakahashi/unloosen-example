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

content_script enable_all_site: true do
  chrome.runtime.onMessage.addListener do |_e|
    title = document.querySelector('h1').textContent

    url = window.location.href
    link = "[#{title}](#{url})"

    input = document.createElement("input")
    input.id = 'tmp-input'
    input.type = "text"
    input.style = "position: absolute; left: -1000px; top: -1000px;"
    input.value = link

    flagment = document.createDocumentFragment()
    flagment.appendChild(input)
    document.body.appendChild(flagment)

    input.select()
    document.execCommand("copy")

    tmp_input = document.querySelector('#tmp-input')
    tmp_input.remove()

    p 'copied'
    true
  end
end

popup do
  query_object = Utils.build_js_object(active: true, currentWindow: true)
  chrome.tabs.query(query_object) do |tabs|
    tab = tabs.at(0)

    chrome.tabs.sendMessage(
      tab[:id],
      'message copy',
    )
  end
end
