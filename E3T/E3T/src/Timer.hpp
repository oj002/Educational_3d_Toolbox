#include <chrono>

namespace E3T
{
	class Timer
	{
	public:
		Timer() noexcept
			:m_start(std::chrono::steady_clock::now())
		{

		}

		template<typename T>
		T restart() noexcept
		{
			const std::chrono::steady_clock::time_point old = m_start;
			m_start = std::chrono::steady_clock::now();
			const std::chrono::duration<T> elapsedTime = m_start - old;
			return elapsedTime.count();
		}

		void restart() noexcept
		{
			m_start = std::chrono::steady_clock::now();
		}

		template<typename T>
		T getElapsedTime() noexcept
		{
			const std::chrono::duration<T> elapsedTime = std::chrono::steady_clock::now() - m_start;
			return elapsedTime.count();
		}


	private:
		std::chrono::steady_clock::time_point m_start;

	};
}