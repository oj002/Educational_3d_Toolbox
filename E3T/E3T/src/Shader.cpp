#include "Shader.hpp"


namespace E3T
{
	Shader::Shader()
		: m_rendererID(0)
	{
		m_vs = CompileShader(GL_VERTEX_SHADER,"#version 400 core\nlayout(location=0)in vec2 aPos;out vec2 fragPos;void main(){fragPos=aPos;gl_Position=vec4(aPos,0.0,1.0);}");
		
		CreateShader("#version 400 core\nin vec2 fragPos;out vec4 fragColor;void main(){fragColor=vec4(0.0,0.0,0.0,1.0);}");
	}

	void Shader::update(const char *filepath)
	{
		static long long lastTimeModified{ 0 };
		const long long time{ fs::last_write_time(fs::current_path().append(filepath)).time_since_epoch().count() };
		if (lastTimeModified < time)
		{
			lastTimeModified = time;
			GLCall(glDeleteProgram(m_rendererID));
			m_uniformLocationCache.clear();
			
			CreateShader(PaseShader(filepath));
			this->bind();
		}
	}

	std::string Shader::PaseLib(const char *libPath)
	{
		const long long lastWriteTime{ fs::last_write_time(fs::current_path().append(libPath)).time_since_epoch().count() };

		if (auto libEntry{ m_libs.find(libPath) }; libEntry != m_libs.end())
			if(libEntry->second.lastWriteTime >= lastWriteTime)
				return libEntry->second.forward_declare;


		m_libs.clear();
		std::ifstream fin(libPath);
		std::string lib_str((std::istreambuf_iterator<char>(fin)), std::istreambuf_iterator<char>());

		Library lib;
		lib.lastWriteTime = lastWriteTime;
		lib.id = CompileShader(GL_FRAGMENT_SHADER, lib_str);

		int brackets = 0;
		for (std::string::iterator it{ lib_str.begin() }; it != lib_str.end(); ++it)
		{
			switch (*it)
			{
			case '/':
			{
				switch (*++it)
				{
				case '/': while (*++it != '\n') {} break;
				case '*':
					while (true)
						if (*++it == '*') 
							if (*++it == '/')
								break;
				break;
				default: --it; break;
				}
			}
			case '\n': case '\r': case '\v': break;
			case '{': ++brackets; break;
			case '}':
				--brackets;
				if (brackets == 0) lib.forward_declare += ';';
				else if (brackets < 0) std::cerr << "Unopened braked closed!" << std::endl;
				break;
			case '#': 
				std::cerr << "You can't use preprocessor directives in lib file" << std::endl;
				break;
			default:
				if (brackets < 1) lib.forward_declare += *it;
				break;
			}
		}

		fin.close();
		m_libs[libPath] = lib;
		return lib.forward_declare;
	}

	std::string Shader::PaseShader(const char *filePath)
	{
		std::ifstream fin(filePath);
		if (!fin.is_open())
		{
			DEBUG_ERROR("Warning: shader '" << filePath << "' doesn't exist\n");
		}

		std::string line;
		std::stringstream ss;
		while (std::getline(fin, line))
		{
			size_t index{ line.find("#import") };
			if (index != std::string::npos)
			{
				const size_t open{ line.find('"', index) + 1 };
				std::string libName{ line.substr(open, line.find('"', open) - open) };

				ss << PaseLib(libName.c_str()) << '\n';
			}
			else
			{
				ss << line << '\n';
			}
		}
		return ss.str();
	}

	unsigned int Shader::CompileShader(unsigned int type, const std::string & sourc)
	{
		GLCall(const unsigned int id = glCreateShader(type));
		const char* src = sourc.c_str();
		GLCall(glShaderSource(id, 1, &src, nullptr));
		GLCall(glCompileShader(id));

		int result;
		GLCall(glGetShaderiv(id, GL_COMPILE_STATUS, &result));
		if (result == GL_FALSE)
		{
			int lenght;
			GLCall(glGetShaderiv(id, GL_INFO_LOG_LENGTH, &lenght));
			char* message = (char*)alloca(lenght * sizeof(char));
			GLCall(glGetShaderInfoLog(id, lenght, &lenght, message));
			std::cout << "Failed to compile Shader: " << message << std::endl;
			GLCall(glDeleteShader(id));
			return 0;
		}

		return id;
	}

	void Shader::CreateShader(const std::string &fragmentShader)
	{
		const unsigned int fs{ CompileShader(GL_FRAGMENT_SHADER, fragmentShader) };
		GLCall(m_rendererID = glCreateProgram());


		GLCall(glAttachShader(m_rendererID, m_vs));
		for (const auto &it : m_libs)
		{
			GLCall(glAttachShader(m_rendererID, it.second.id));
		}
		GLCall(glAttachShader(m_rendererID, fs));
		GLCall(glLinkProgram(m_rendererID));
		GLCall(glValidateProgram(m_rendererID));

		GLCall(glDeleteShader(fs));
	}


	int Shader::getUniformLocation(const std::string & name)
	{
		if (m_uniformLocationCache.find(name) != m_uniformLocationCache.end())
		{
			return m_uniformLocationCache[name];
		}
		GLCall(int location = glGetUniformLocation(m_rendererID, name.c_str()));
		if (location == -1)
		{
			std::cout << "Warning: uniform '" << name << "' doesn't exist\n";
		}

		m_uniformLocationCache[name] = location;
		return location;
	}
}
