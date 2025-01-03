import { useEffect, useState } from "react";
import { AnimatePresence, motion } from "framer-motion";
import fieLogo from "./assets/fie_logo.svg";
import Sorteador from "./components/Sorteador";
import GradientButton from "./components/GradientButton";
import { confetti } from "@tsparticles/confetti";
import Winner from "./types/winner";
import WinnerCard from "./components/WinnerCard";
import { randomInRange } from "./utils/utils";
import backendClient from "./config/backend";
import banner1 from "./assets/banner1.webp";
import banner2 from "./assets/banner2.webp";
import bannerAJ from "./assets/bannerAJ.webp";
import AdvancedImageLoader from "./components/ImageWithLoader";

const defaults = { startVelocity: 30, spread: 360, ticks: 60, zIndex: 0 };

export default function App() {
  const [currentWinner, setCurrentWinner] = useState<Winner | null>(null);
  const [isloading, setIsLoading] = useState(false);
  const [showConfetti, setShowConfetti] = useState(false);
  const [showWinnerCard, setShowWinnerCard] = useState(false);
  const [rouletteFlex1, setRouletteFlex1] = useState(true);
  const [buttonSortearDisabled, setButtonSortearDisabled] = useState(false);
  const [newRaffle, setNewRaffle] = useState(false);
  const [winnerCount, setWinnerCount] = useState(0);
  const [isResetLoading, setIsResetLoading] = useState(false);
  useEffect(() => {
    backendClient
      .get("/api/v1/cantidad_ganadores")
      .then((response) => {
        setWinnerCount(response.data.total_ganadores);
      })
      .catch((error) => {
        console.error(error);
        setShowWinnerCard(false);
        setShowConfetti(false);
        setRouletteFlex1(true);
        alert("Error al obtener la cantidad de ganadores");
      });
  }, [currentWinner]);

  const handleSortear = () => {
    if (winnerCount >= 5) {
      alert("Se llegó al límite máximo de ganadores");
      setShowWinnerCard(false);
      setShowConfetti(false);
      setRouletteFlex1(true);
      return;
    }
    if (currentWinner && showWinnerCard && !newRaffle) {
      setNewRaffle(true);
      return;
    }
    if (newRaffle) {
      setNewRaffle(false);
      setCurrentWinner(null);
    }
    setIsLoading(true);
    setShowWinnerCard(false);
    setShowConfetti(false);
    setButtonSortearDisabled(true);

    backendClient
      .get("/api/v1/obtener_ganador")
      .then((response) => {
        setIsLoading(false);
        setCurrentWinner(response.data);
      })
      .catch((error) => {
        console.error(error);
        alert("Error al obtener el ganador");
        setIsLoading(false);
        setShowWinnerCard(false);
        setShowConfetti(false);
      });
  };

const handleReset = async () => {
  setButtonSortearDisabled(true);
  setIsResetLoading(true); 

  try {
    await backendClient.delete("/api/v1/resetear_ganadores", {
      timeout: 180000, 
    });

    setShowConfetti(false);
    setWinnerCount(0);
    setCurrentWinner(null);
    setRouletteFlex1(true);
    setShowWinnerCard(false);
    setNewRaffle(false);
    window.location.reload();
  } catch (error) {
    console.error(error);
    alert("Error al resetear los ganadores");
  } finally {
    setIsResetLoading(false); 
  }
};
  const handleDownload = () => {
    backendClient
      .get("/api/v1/descargar_ganadores", {
        responseType: "blob",
      })
      .then((response) => {
        const url = window.URL.createObjectURL(new Blob([response.data]));
        const link = document.createElement("a");
        link.href = url;
        link.setAttribute("download", "ganadores.csv");
        document.body.appendChild(link);
        link.click();
      })
      .catch((error) => {
        console.error(error);
        alert("Error al descargar el archivo");
      });
  };

  useEffect(() => {
    if (showConfetti) {
      const duration = 15 * 1000; // 15 seconds
      const animationEnd = Date.now() + duration;
      const interval = setInterval(() => {
        const timeLeft = animationEnd - Date.now();
        if (timeLeft <= 0) {
          clearInterval(interval);
          setShowConfetti(false);
          return;
        }
        const particleCount = 40 * (timeLeft / duration);
        confetti(
          Object.assign({}, defaults, {
            particleCount,
            origin: { x: randomInRange(0.1, 0.3), y: Math.random() - 0.2 },
          })
        );
        confetti(
          Object.assign({}, defaults, {
            particleCount,
            origin: { x: randomInRange(0.4, 0.6), y: Math.random() - 0.2 },
          })
        );
        confetti(
          Object.assign({}, defaults, {
            particleCount,
            origin: { x: randomInRange(0.7, 0.9), y: Math.random() - 0.5 },
          })
        );
      }, 300);

      return () => clearInterval(interval);
    }
  }, [showConfetti]);

  return (
    <div className="h-screen flex flex-col max-h-screen overflow-hidden">
      <main className="flex-1 grid grid-cols-1 md:grid-cols-4 min-h-">
        <div className="col-span-1 flex flex-col items-start justify-between min-h-0">
          <div className="w-full h-full bg-white flex flex-col justify-center items-center">
          <AdvancedImageLoader
            src={banner1}
            alt="Banner 1"
            className="object-contain w-full h-full"
          />
          </div>
        </div>

        <div className="col-span-2 flex flex-col items-center justify-center h-full">
          <div className="object-contain flex flex-col items-center h-full w-full">
            <a
              href="https://www.bancofie.com.bo/"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-block"
              style={{ maxWidth: "100%", height: "auto" }}
            >
             <AdvancedImageLoader
              src={fieLogo}
              alt="FIE"
              className="object-contain w-full h-auto mt-4"
              style={{ maxWidth: "340px" }}
            />
            </a>

            <motion.div
              className="flex flex-col items-center justify-center max-w-full"
              initial={{ flex: 1 }}
              animate={{
                flex: rouletteFlex1 ? 1 : 0,
              }}
              transition={{ duration: 0.5, ease: "easeInOut" }}
            >
              <Sorteador
                currentTicket={currentWinner?.TicketGanador || 0}
                isLoading={isloading}
                setShowConfetti={setShowConfetti}
                setShowWinnerCard={setShowWinnerCard}
                setRouletteFlex1={setRouletteFlex1}
                setButtonSortearDisabled={setButtonSortearDisabled}
              />
            </motion.div>

            <AnimatePresence
              onExitComplete={() => {
                setRouletteFlex1(true);
              }}
            >
              {currentWinner && showWinnerCard && !newRaffle && (
                <motion.div
                  style={{ maxWidth: "100%" }}
                  initial={{ opacity: 0, y: 50 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: 50 }}
                  transition={{ duration: 0.5 }}
                >
                  <WinnerCard winner={currentWinner} />
                </motion.div>
              )}
            </AnimatePresence>
          </div>

          <AnimatePresence>
            <motion.div
              className={`object-contain mb-4 flex ${
                newRaffle ? "flex-col gap-4" : "flex-row gap-4"
              } items-center justify-between`}
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.5 }}
            >
              {winnerCount < 5 && (
                <GradientButton
                  onClick={handleSortear}
                  disabled={buttonSortearDisabled}
                >
                  {currentWinner && showWinnerCard && !newRaffle
                    ? "Nuevo sorteo"
                    : "Sortear"}
                </GradientButton>
              )}
              {currentWinner && showWinnerCard && (
                <GradientButton
                  onClick={handleDownload}
                  disabled={buttonSortearDisabled || !currentWinner}
                >
                  Descargar
                </GradientButton>
              )}
              {(newRaffle || winnerCount >= 5) && (
                <GradientButton
                  onClick={handleReset}
                  disabled={
                    buttonSortearDisabled || (!currentWinner && winnerCount < 5)
                  }
                >
                  Resetear Ganadores
                </GradientButton>
              )}
            </motion.div>
          </AnimatePresence>
          
          {isResetLoading && (
            <div className="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
              <div className="bg-white p-6 rounded-lg flex items-center gap-4">
                <div className="w-8 h-8 border-4 border-pink-500 border-solid rounded-full border-t-transparent animate-spin"></div>
                <p>Esto puede demorar unos minutos...</p>
              </div>
            </div>
          )}

          <div className="flex flex-col items-start justify-between h-1/4 w-full">
            <div className="w-full h-full bg-white flex flex-col justify-center items-center">
            </div>
          </div>

          <div className="w-full bg-white flex flex-col justify-center items-center pb-4">
          <AdvancedImageLoader
            src={bannerAJ}
            alt="Banner AJ"
            className="object-contain w-full h-[130px]"
          />
          </div>
        </div>

        <div className="col-span-1 flex flex-col items-start justify-between min-h-0">
          <div className="w-full h-full bg-white flex flex-col justify-center items-center">
          <AdvancedImageLoader
            src={banner2}
            alt="Banner 2"
            className="object-contain w-full h-auto"
          />
          </div>
        </div>
      </main>
    </div>
  );
}
