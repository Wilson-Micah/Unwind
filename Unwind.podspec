Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '9.1'
s.name = "Unwind"
s.summary = "Unwind is a JSON parsing library using infix and postfix operators."
s.requires_arc = true

# 2
s.version = "0.1.0"

# 3
s.license = { :type => "MIT", :file => "../LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "Micah Wilson" => "micahw@sisna.com" }


# 5 - Replace this URL with your own Github page's URL (from the address bar)
s.homepage = "https://github.com/MicahTWilson/Unwind"


# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/MicahTWilson/Unwind.git", :tag => "#{s.version}"}

# 8
s.source_files = "Unwind/**/*.{swift}"

end
